//
//  GeneralSettingsViewController.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit
import Combine
import UserNotifications

final class GeneralSettingsViewController: UIViewController {

    // MARK: - Properties

    private var settingsView: GeneralSettingsView {
        return view as! GeneralSettingsView
    }

    weak var coordinator: MainTabBarCoordinator?
    private let viewModel: GeneralSettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: GeneralSettingsViewModel = GeneralSettingsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = GeneralSettingsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupAppVersion()
        setupBindings()
        setupNotificationObserver()

        // Hide navigation bar immediately in viewDidLoad
        navigationController?.setNavigationBarHidden(true, animated: false)

        // 초기 토글 상태 로드
        Task {
            await viewModel.loadToggleStatus()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}

// MARK: - Setup

extension GeneralSettingsViewController {
    private func setupActions() {
        // Back button
        settingsView.backButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )

        // Notification toggles
        settingsView.postLikeNotificationRow.toggleSwitch.addTarget(
            self,
            action: #selector(postLikeNotificationToggled),
            for: .valueChanged
        )

        settingsView.appPushNotificationRow.toggleSwitch.addTarget(
            self,
            action: #selector(appPushNotificationToggled),
            for: .valueChanged
        )

        // Row tap gestures
        let termsGesture = UITapGestureRecognizer(target: self, action: #selector(termsOfServiceTapped))
        settingsView.termsOfServiceRow.addGestureRecognizer(termsGesture)

        let privacyGesture = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyTapped))
        settingsView.privacyPolicyRow.addGestureRecognizer(privacyGesture)

        let logoutGesture = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        settingsView.logoutRow.addGestureRecognizer(logoutGesture)

        // Delete account button
        settingsView.deleteAccountButton.addTarget(
            self,
            action: #selector(deleteAccountTapped),
            for: .touchUpInside
        )
    }

    private func setupAppVersion() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            settingsView.updateAppVersion(version)
        }
    }

    private func setupBindings() {
        // 앱 푸시 토글 상태 바인딩
        viewModel.$appPushEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.settingsView.appPushNotificationRow.setToggle(isEnabled)
            }
            .store(in: &cancellables)

        // 좋아요 알림 토글 상태 바인딩
        viewModel.$recordPushEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.settingsView.postLikeNotificationRow.setToggle(isEnabled)
            }
            .store(in: &cancellables)

        // 에러 처리
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error.userMessage)
            }
            .store(in: &cancellables)
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
}

// MARK: - Actions

extension GeneralSettingsViewController {
    @objc private func backButtonTapped() {
        // Pop if there are view controllers to pop to, otherwise dismiss
        if let navController = navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func postLikeNotificationToggled(_ sender: UISwitch) {
        print("📱 [GeneralSettings] Post like notification toggled: \(sender.isOn)")
        Task {
            await viewModel.toggleRecordPush(active: sender.isOn)
        }
    }

    @objc private func appPushNotificationToggled(_ sender: UISwitch) {
        print("📱 [GeneralSettings] App push notification toggled: \(sender.isOn)")

        // off → on 전환 시에만 시스템 권한 체크
        if sender.isOn {
            Task {
                let hasPermission = await checkSystemNotificationPermission()
                if !hasPermission {
                    // 권한 없으면 토글 off로 되돌리고 팝업 표시
                    await MainActor.run {
                        viewModel.appPushEnabled = false
                        showNotificationPermissionAlert()
                    }
                } else {
                    // 권한 있으면 API 호출
                    await viewModel.toggleAppPush(active: true)
                }
            }
        } else {
            // on → off는 그냥 API 호출
            Task {
                await viewModel.toggleAppPush(active: false)
            }
        }
    }

    @objc private func termsOfServiceTapped() {
        let vc = TermsViewController(termsType: .termsOfService)
        present(vc, animated: true)
    }

    @objc private func privacyPolicyTapped() {
        let vc = TermsViewController(termsType: .privacyPolicy)
        present(vc, animated: true)
    }

    @objc private func logoutTapped() {
        showLogoutPopup()
    }

    @objc private func deleteAccountTapped() {
        let vc = DeleteAccountViewController()
        vc.coordinator = coordinator
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showLogoutPopup() {
        let popup = CommonPopupViewController(
            title: "로그아웃 하시겠습니까?",
            message: "",
            primaryButtonTitle: "로그아웃",
            secondaryButtonTitle: "닫기"
        )

        popup.onPrimaryAction = { [weak self] in
            self?.performLogout()
        }

        present(popup, animated: true)
    }

    private func performLogout() {
        do {
            // Delete tokens only (guestUserId는 유지하여 재로그인 시 복원 가능)
            try TokenStorage.shared.deleteTokens()

            // Delete onboarding data (optional)
            try? OnboardingDataStorage.shared.delete()

            print("✅ Logout successful")

            // Notify AppCoordinator
            coordinator?.parentCoordinator?.logout()

        } catch let appError as AppError {
            print("❌ Logout failed: \(appError)")
            showError(appError.userMessage)
        } catch {
            print("❌ Logout failed: \(error)")
            showError(error.localizedDescription)
        }
    }

    private func showError(_ message: String) {
        ToastView.showError(message: message)
    }

    /// 시스템 알림 권한 확인
    private func checkSystemNotificationPermission() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    /// 알림 권한 허용 팝업 표시
    private func showNotificationPermissionAlert() {
        let popup = CommonPopupViewController(
            title: "알림 권한 허용",
            message: "알림이 꺼져있으면 중요한 소식을 놓칠 수 있어요. 기기설정에서 알림을 허용해 주세요.",
            primaryButtonTitle: "설정하기",
            secondaryButtonTitle: "취소"
        )

        popup.onPrimaryAction = { [weak self] in
            // 시스템 설정으로 이동
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        popup.onSecondaryAction = { [weak self] in
            // 토글 off로 복구
            self?.viewModel.appPushEnabled = false
        }

        present(popup, animated: true)
    }

    /// 앱이 foreground로 돌아올 때 호출
    @objc private func handleAppWillEnterForeground() {
        Task {
            await viewModel.checkAndSyncSystemNotification()
        }
    }
}

#if DEBUG
#Preview {
    GeneralSettingsViewController()
}
#endif
