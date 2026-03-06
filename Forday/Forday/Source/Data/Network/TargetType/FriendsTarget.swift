//
//  FriendsTarget.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import Foundation
import Moya
import Alamofire

enum FriendsTarget {
    case blockUser(request: DTO.BlockUserRequest)  /// 사용자 차단
    case reportUser(request: DTO.ReportUserRequest) /// 사용자 신고
}

extension FriendsTarget: BaseTargetType {

    var path: String {
        switch self {
        case .blockUser:
            return FriendsAPI.blockUser.endpoint
        case .reportUser:
            return FriendsAPI.reportUser.endpoint
        }
    }

    var method: Moya.Method {
        switch self {
        case .blockUser:
            return .post
        case .reportUser:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .blockUser(let request):
            return .requestJSONEncodable(request)
        case .reportUser(let request):
            return .requestJSONEncodable(request)
        }
    }
}
