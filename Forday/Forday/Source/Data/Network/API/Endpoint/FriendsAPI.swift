//
//  FriendsAPI.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

enum FriendsAPI {
    case blockUser  /// 사용자 차단
    case reportUser /// 사용자 신고

    var endpoint: String {
        switch self {
        case .blockUser:
            return "/friends/block"
        case .reportUser:
            return "/friends/report"
        }
    }
}
