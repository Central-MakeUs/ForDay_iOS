//
//  GeneralSettingsViewModel.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import Foundation
import Combine
import UserNotifications

final class GeneralSettingsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var appPushEnabled = false
    @Published var recordPushEnabled = false
    @Published var isLoading = false
    @Published var error: AppError?

    // MARK: - Private Properties

    private let fetchToggleStatusUseCase: FetchNotificationToggleStatusUseCase
    private let toggleNotificationUseCase: ToggleNotificationUseCase

    // MARK: - Initialization

    init(
        fetchToggleStatusUseCase: FetchNotificationToggleStatusUseCase = FetchNotificationToggleStatusUseCase(),
        toggleNotificationUseCase: ToggleNotificationUseCase = ToggleNotificationUseCase()
    ) {
        self.fetchToggleStatusUseCase = fetchToggleStatusUseCase
        self.toggleNotificationUseCase = toggleNotificationUseCase
    }

    // MARK: - Public Methods

    /// 토글 상태 조회
    @MainActor
    func loadToggleStatus() async {
        isLoading = true
        error = nil

        do {
            let status = try await fetchToggleStatusUseCase.execute()
            appPushEnabled = status.appPushEnabled
            recordPushEnabled = status.recordPushEnabled
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .unknown(error)
        }

        isLoading = false
    }

    /// 앱 푸시 알림 토글
    @MainActor
    func toggleAppPush(active: Bool) async {
        error = nil

        do {
            let success = try await toggleNotificationUseCase.execute(active: active, toggleType: "APP")
            if success {
                appPushEnabled = active
            }
        } catch let appError as AppError {
            error = appError
            // 토글 실패 시 원래 상태로 되돌림
            appPushEnabled = !active
        } catch {
            self.error = .unknown(error)
            // 토글 실패 시 원래 상태로 되돌림
            appPushEnabled = !active
        }
    }

    /// 좋아요 알림 토글 (게시글 관련 알림)
    @MainActor
    func toggleRecordPush(active: Bool) async {
        error = nil

        do {
            let success = try await toggleNotificationUseCase.execute(active: active, toggleType: "RECORD")
            if success {
                recordPushEnabled = active
            }
        } catch let appError as AppError {
            error = appError
            // 토글 실패 시 원래 상태로 되돌림
            recordPushEnabled = !active
        } catch {
            self.error = .unknown(error)
            // 토글 실패 시 원래 상태로 되돌림
            recordPushEnabled = !active
        }
    }

    /// 시스템 알림 권한 확인 및 APP 토글 자동 활성화
    @MainActor
    func checkAndSyncSystemNotification() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        let systemEnabled = settings.authorizationStatus == .authorized

        // 시스템 알림이 활성화되어 있고, 앱 푸시가 비활성화되어 있으면 자동으로 활성화
        if systemEnabled && !appPushEnabled {
            await toggleAppPush(active: true)
        }
    }
}
