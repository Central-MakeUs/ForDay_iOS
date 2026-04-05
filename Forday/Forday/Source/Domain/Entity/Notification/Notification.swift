//
//  Notification.swift
//  Forday
//
//  Created by Subeen on 4/3/26.
//

import Foundation

struct NotificationList {
    let pushInfo: PushInfo
    let notificationList: [NotificationItem]
    let hasNext: Bool
    let lastNotificationId: String?
}

struct PushInfo {
    let pushEnabled: Bool
    let message: String?
}

struct NotificationItem: Identifiable {
    let id: Int  // Identifiable 프로토콜용
    let notificationId: Int  // 서버 응답 필드
    let imageUrl: URL?
    let message: String
    let type: NotificationType
    let reactionAlarm: ReactionAlarm?
    let commentAlarm: CommentAlarm?
    let read: Bool
    let senderProfileUrl: URL?
    let createdAt: String

    /// 알림 타입에 따라 recordId 반환 (ActivityDetail 네비게이션용)
    var recordId: Int? {
        if let reaction = reactionAlarm {
            return reaction.recordId
        }
        if let comment = commentAlarm {
            return comment.recordId
        }
        return nil
    }
}

enum NotificationType: String {
    case recordComment = "RECORD_COMMENT"
    case recordReaction = "RECORD_REACTION"
    case friend = "FRIEND"
    case unknown = ""
}

struct ReactionAlarm {
    let reactionType: String
    let recordId: Int
}

struct CommentAlarm {
    let recordId: Int
    let commentId: Int
    let commentContent: String
}
