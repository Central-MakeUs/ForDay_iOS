//
//  NotificationTarget.swift
//  Forday
//
//  Created by Subeen on 4/3/26.
//

import Foundation
import Moya
import Alamofire

enum NotificationTarget {
    case updateFCMToken(request: DTO.FCMTokenUpdateRequest)
    case fetchNotifications(filterType: String, lastNotificationId: String?, pageSize: Int)
    case toggleNotification(request: DTO.NotificationToggleRequest)
    case fetchToggleStatus
}

extension NotificationTarget: BaseTargetType {
    var path: String {
        switch self {
        case .updateFCMToken:
            return "/app/fcm-token"
        case .fetchNotifications:
            return "/api/notifications"
        case .toggleNotification, .fetchToggleStatus:
            return "/api/notifications/toggle"
        }
    }

    var method: Moya.Method {
        switch self {
        case .updateFCMToken, .toggleNotification:
            return .patch
        case .fetchNotifications, .fetchToggleStatus:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .updateFCMToken(let request):
            return .requestJSONEncodable(request)
        case .fetchNotifications(let filterType, let lastNotificationId, let pageSize):
            var params: [String: Any] = [
                "filterType": filterType,
                "pageSize": pageSize
            ]
            if let lastId = lastNotificationId {
                params["lastNotificationId"] = lastId
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case .toggleNotification(let request):
            return .requestJSONEncodable(request)
        case .fetchToggleStatus:
            return .requestPlain
        }
    }
}
