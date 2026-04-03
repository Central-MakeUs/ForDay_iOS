//
//  NotificationResponse.swift
//  Forday
//
//  Created by Subeen on 4/3/26.
//

import Foundation

extension DTO {
    
    // MARK: - Notification List
    
    struct NotificationListResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: NotificationListData
    }

    struct NotificationListData: Codable {
        let pushInfo: PushInfoData
        let notificationList: [NotificationItemData]
        let hasNext: Bool
        let lastNotificationId: String?
    }

    struct PushInfoData: Codable {
        let pushEnabled: Bool
        let message: String?
    }

    struct NotificationItemData: Codable {
        let notificationId: Int
        let imageUrl: String?
        let message: String
        let type: String
        let reactionAlram: ReactionAlarmData?
        let commentAlram: CommentAlarmData?
        let read: Bool
        let senderProfileUrl: String?
        let createdAt: String
    }

    struct ReactionAlarmData: Codable {
        let reactionType: String
        let recordId: Int
    }

    struct CommentAlarmData: Codable {
        let recordId: Int
        let commentId: Int
        let commentContent: String
    }

    // MARK: - Toggle Response
    
    struct NotificationToggleResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: NotificationToggleData
    }

    struct NotificationToggleData: Codable {
        let message: String
        let active: Bool
        let toggleType: String
    }

    // MARK: - FCM Token Update Response
    
    struct FCMTokenUpdateResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: FCMTokenUpdateData
    }

    struct FCMTokenUpdateData: Codable {
        let message: String
        let fcmToken: String
        let deviceId: String
    }
}
