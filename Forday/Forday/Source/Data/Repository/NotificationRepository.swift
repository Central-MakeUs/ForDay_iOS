//
//  NotificationRepository.swift
//  Forday
//
//  Created by Subeen on 4/3/26.
//

import Foundation
import Moya

final class NotificationRepository: NotificationRepositoryInterface {
    
    private let provider: MoyaProvider<NotificationTarget>
    
    init(provider: MoyaProvider<NotificationTarget> = NetworkProvider.createProvider()) {
        self.provider = provider
    }
    
    // MARK: - FCM Token Update
    
    func updateFCMToken(fcmToken: String, deviceId: String) async throws -> Bool {
        let request = DTO.FCMTokenUpdateRequest(fcmToken: fcmToken, deviceId: deviceId)
        let response: DTO.FCMTokenUpdateResponse = try await provider.request(.updateFCMToken(request: request))
        return response.success
    }
    
    // MARK: - Fetch Notifications
    
    func fetchNotifications(filterType: String, lastNotificationId: String?, pageSize: Int) async throws -> NotificationList {
        let response: DTO.NotificationListResponse = try await provider.request(
            .fetchNotifications(filterType: filterType, lastNotificationId: lastNotificationId, pageSize: pageSize)
        )
        return response.data.toDomain()
    }
    
    // MARK: - Toggle Notification
    
    func toggleNotification(active: Bool, toggleType: String) async throws -> Bool {
        let request = DTO.NotificationToggleRequest(active: active, toggleType: toggleType)
        let response: DTO.NotificationToggleResponse = try await provider.request(.toggleNotification(request: request))
        return response.success
    }
}

// MARK: - Mappings

extension DTO.NotificationListData {
    func toDomain() -> NotificationList {
        return NotificationList(
            pushInfo: pushInfo.toDomain(),
            notificationList: notificationList.map { $0.toDomain() },
            hasNext: hasNext,
            lastNotificationId: lastNotificationId
        )
    }
}

extension DTO.PushInfoData {
    func toDomain() -> PushInfo {
        return PushInfo(
            pushEnabled: pushEnabled,
            message: message
        )
    }
}

extension DTO.NotificationItemData {
    func toDomain() -> NotificationItem {
        return NotificationItem(
            id: notificationId,  // Identifiable용
            notificationId: notificationId,  // 실제 서버 필드
            imageUrl: URL(string: imageUrl ?? ""),
            message: message,
            type: NotificationType(rawValue: type) ?? .unknown,
            reactionAlarm: reactionAlram?.toDomain(),
            commentAlarm: commentAlram?.toDomain(),
            read: read,
            senderProfileUrl: URL(string: senderProfileUrl ?? ""),
            createdAt: createdAt
        )
    }
}

extension DTO.ReactionAlarmData {
    func toDomain() -> ReactionAlarm {
        return ReactionAlarm(
            reactionType: reactionType,
            recordId: recordId
        )
    }
}

extension DTO.CommentAlarmData {
    func toDomain() -> CommentAlarm {
        return CommentAlarm(
            recordId: recordId,
            commentId: commentId,
            commentContent: commentContent
        )
    }
}
