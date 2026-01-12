//
//  UsersTarget.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation
import Moya
import Alamofire

enum UsersTarget {
    case nicknameAvailability(nickname: String)
    case setNickname(request: DTO.SetNicknameRequest)
}

extension UsersTarget: BaseTargetType {
    
    var path: String {
        switch self {
        case .nicknameAvailability:
            return UsersAPI.nicknameAvailability.endpoint
        case .setNickname:
            return UsersAPI.settingNickname.endpoint
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .nicknameAvailability:
            return .get
        case .setNickname:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .nicknameAvailability(let nickname):

            let parameters = ["nickname": nickname]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
        case .setNickname(let request):
            return .requestJSONEncodable(request)
        }
    }
    
    
}
