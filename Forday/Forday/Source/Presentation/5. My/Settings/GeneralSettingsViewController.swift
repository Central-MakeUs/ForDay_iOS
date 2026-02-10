//
//  GeneralSettingsViewController.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit

final class GeneralSettingsViewController: UIViewController {

    // MARK: - Properties

    private var settingsView: GeneralSettingsView {
        return view as! GeneralSettingsView
    }

    weak var coordinator: MainTabBarCoordinator?

    // MARK: - Lifecycle

    override func loadView() {
        view = GeneralSettingsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupAppVersion()

        // Hide navigation bar immediately in viewDidLoad
        navigationController?.setNavigationBarHidden(true, animated: false)
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
}

// MARK: - Actions

extension GeneralSettingsViewController {
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
            // Delete tokens
            try TokenStorage.shared.deleteAllTokens()

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
}

#if DEBUG
#Preview {
    GeneralSettingsViewController()
}
#endif
