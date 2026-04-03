//
//  NotificationRequest.swift
//  Forday
//
//  Created by Subeen on 4/3/26.
//

import Foundation

extension DTO {
    /// FCM 토큰 갱신 요청
    struct FCMTokenUpdateRequest: BaseRequest {
        let fcmToken: String
        let deviceId: String
    }

    /// 알림 토글 설정 요청
    struct NotificationToggleRequest: BaseRequest {
        let active: Bool
        let toggleType: String // APP, RECORD
    }
}
