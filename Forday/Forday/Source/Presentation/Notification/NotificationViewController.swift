//
//  NotificationViewController.swift
//  Forday
//
//  Created by Subeen on 4/5/26.
//

import UIKit
import Combine
import UserNotifications

final class NotificationViewController: UIViewController {

    // MARK: - Properties

    private let notificationView = NotificationView()
    private let viewModel = NotificationViewModel()
    private var cancellables = Set<AnyCancellable>()

    weak var coordinator: MainTabBarCoordinator?

    // MARK: - Lifecycle

    override func loadView() {
        view = notificationView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupActions()
        bind()

        // 권한 체크 후 데이터 로드
        Task {
            await viewModel.checkSystemNotificationPermission()
            if viewModel.systemNotificationEnabled {
                await viewModel.loadNotifications(reset: true)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 권한 체크 후 권한이 있으면 데이터 새로고침
        Task {
            await viewModel.checkSystemNotificationPermission()
            if viewModel.systemNotificationEnabled {
                await viewModel.loadNotifications(reset: true)
            }
        }
    }

    // MARK: - Setup

    private func setupTableView() {
        notificationView.tableView.delegate = self
        notificationView.tableView.dataSource = self
    }

    private func setupActions() {
        // Back button
        notificationView.backButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )

        // Settings button
        notificationView.settingsButton.addTarget(
            self,
            action: #selector(settingsButtonTapped),
            for: .touchUpInside
        )

        // Permission banner tap (navigate to system settings)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(permissionBannerTapped))
        notificationView.permissionBannerView.addGestureRecognizer(tapGesture)

        // Pull to refresh
        notificationView.refreshControl.addTarget(
            self,
            action: #selector(refreshNotifications),
            for: .valueChanged
        )
    }

    private func bind() {
        // Notifications
        viewModel.$notifications
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notifications in
                self?.notificationView.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)

        // Loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.notificationView.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        // Error handling
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.handleAppError(error)
            }
            .store(in: &cancellables)

        // System notification permission state
        viewModel.$systemNotificationEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.updatePermissionBanner(enabled: enabled)
            }
            .store(in: &cancellables)
    }

    // MARK: - UI Updates

    private func updatePermissionBanner(enabled: Bool) {
        if enabled {
            notificationView.hidePermissionBanner()
        } else {
            notificationView.showPermissionBanner()
        }

        // 권한 상태 변경 시 EmptyState도 업데이트
        updateEmptyState()
    }

    private func updateEmptyState() {
        // 권한이 없으면 권한 거부 화면 표시
        if !viewModel.systemNotificationEnabled {
            notificationView.showPermissionDeniedState()
            return
        }

        // 권한은 있는데 알림이 없으면 알림 없음 화면 표시
        let hasNotifications = !viewModel.notifications.isEmpty
        if hasNotifications {
            notificationView.hideEmptyState()
        } else {
            notificationView.showEmptyState()
        }
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func settingsButtonTapped() {
        coordinator?.showGeneralSettings()
    }

    @objc private func permissionBannerTapped() {
        showNotificationPermissionPopup()
    }

    /// 알림 권한 허용 팝업 표시
    private func showNotificationPermissionPopup() {
        let popup = CommonPopupViewController(
            title: "알림 권한 허용",
            message: "알림이 꺼져있으면 중요한 소식을 놓칠 수 있어요. 기기설정에서 알림을 허용해 주세요.",
            primaryButtonTitle: "설정하기",
            secondaryButtonTitle: "취소"
        )

        popup.onPrimaryAction = { [weak self] in
            // 시스템 설정으로 이동
            self?.viewModel.openSystemSettings()
        }

        popup.onSecondaryAction = {
            // 팝업만 닫기
        }

        present(popup, animated: true)
    }

    @objc private func refreshNotifications() {
        Task {
            // 권한 체크 후 권한이 있을 때만 데이터 로드
            await viewModel.checkSystemNotificationPermission()
            if viewModel.systemNotificationEnabled {
                await viewModel.loadNotifications(reset: true)
            } else {
                // 권한이 없으면 refresh control만 종료
                notificationView.refreshControl.endRefreshing()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationCell.identifier,
            for: indexPath
        ) as? NotificationCell else {
            return UITableViewCell()
        }

        let notification = viewModel.notifications[indexPath.row]
        cell.configure(with: notification)
        cell.delegate = self

        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Infinite scroll
        Task {
            await viewModel.loadMoreIfNeeded(currentIndex: indexPath.row)
        }
    }
}

// MARK: - NotificationCellDelegate

extension NotificationViewController: NotificationCellDelegate {
    func notificationCellDidTap(_ cell: NotificationCell, notification: NotificationItem) {
        // recordId가 없는 알림은 네비게이션 불가 (예: FRIEND 타입)
        guard let recordId = notification.recordId else {
            print("⚠️ [Notification] recordId가 없는 알림입니다 (type: \(notification.type))")
            return
        }

        // Navigate to ActivityDetail with notificationId
        // notificationId를 전달하면 서버에서 자동으로 read 처리됨
        // context는 USER_FEED 사용 (서버에 NOTIFICATION context 없음)
        let context = ActivityDetailContext(
            contextType: .userFeed,
            userId: nil,  // 본인 기준
            keyword: nil,
            hobbyIds: nil,
            notificationId: notification.notificationId
        )

        coordinator?.showActivityDetailWithContext(
            activityRecordId: recordId,
            context: context
        )
    }
}
