//
//  NotificationViewModel.swift
//  Forday
//
//  Created by Subeen on 4/5/26.
//

import Foundation
import Combine
import UserNotifications

final class NotificationViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var notifications: [NotificationItem] = []
    @Published var pushInfo: PushInfo?
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var systemNotificationEnabled = false

    // MARK: - Private Properties

    private let fetchNotificationsUseCase: FetchNotificationsUseCase
    private var hasNext = false
    private var lastNotificationId: String?
    private var selectedFilterType = "ALL"  // TODO: 필터 기능 확장 시 사용 (ALL, RECORD, FRIEND, GROUP)
    private let pageSize = 20

    // MARK: - Initialization

    init(fetchNotificationsUseCase: FetchNotificationsUseCase = FetchNotificationsUseCase()) {
        self.fetchNotificationsUseCase = fetchNotificationsUseCase
    }

    // MARK: - Public Methods

    /// 알림 목록 로드 (초기 로드 또는 새로고침)
    @MainActor
    func loadNotifications(reset: Bool = false) async {
        guard !isLoading else { return }

        if reset {
            lastNotificationId = nil
            hasNext = false
        }

        isLoading = true
        error = nil

        do {
            let result = try await fetchNotificationsUseCase.execute(
                filterType: selectedFilterType,
                lastNotificationId: lastNotificationId,
                pageSize: pageSize
            )

            if reset {
                notifications = result.notificationList
            } else {
                notifications.append(contentsOf: result.notificationList)
            }

            pushInfo = result.pushInfo
            hasNext = result.hasNext
            lastNotificationId = result.lastNotificationId

        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .unknown(error)
        }

        isLoading = false
    }

    /// 무한 스크롤 - 더 로드할 항목이 있는지 확인
    @MainActor
    func loadMoreIfNeeded(currentIndex: Int) async {
        guard !isLoading,
              hasNext,
              currentIndex >= notifications.count - 5 else { return }

        await loadNotifications(reset: false)
    }

    /// 시스템 알림 권한 확인
    func checkSystemNotificationPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            let status = settings.authorizationStatus
            systemNotificationEnabled = (status == .authorized || status == .provisional || status == .ephemeral)
        }
    }

    /// 시스템 설정으로 이동
    func openSystemSettings() {
        PushNotificationService.shared.openSettings()
    }

    // TODO: 필터 선택 (확장성을 위해 구조만 준비)
    // @MainActor
    // func selectFilter(_ filterType: String) async {
    //     guard filterType != selectedFilterType else { return }
    //     selectedFilterType = filterType
    //     await loadNotifications(reset: true)
    // }
}
