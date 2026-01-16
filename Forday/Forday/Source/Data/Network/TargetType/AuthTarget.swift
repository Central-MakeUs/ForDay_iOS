//
//  AuthTarget.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation
import Moya
import Alamofire

enum AuthTarget {
    case kakaoLogin(request: DTO.KakaoLoginRequest)
//    case appleLogin(request: DTO.AppleLoginRequest)
    case guestLogin(request: DTO.GuestLoginRequest)
    case refreshToken(request: DTO.TokenRefreshRequest)
    case validateToken
//    case logout
}

extension AuthTarget: BaseTargetType {
    
    var baseURL: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    var path: String {
        switch self {
        case .kakaoLogin:
            return AuthAPI.kakaoLogin.endpoint
//        case .appleLogin:
//            return AuthAPI.appleLogin.endpoint
        case .guestLogin:
            return AuthAPI.guestLogin.endpoint
        case .refreshToken:
            return AuthAPI.refreshToken.endpoint
        case .validateToken:
            return "/auth/validate"
//        case .logout:
//            return AuthAPI.logout.endpoint
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .kakaoLogin, .guestLogin, .refreshToken /*, .appleLogin, .logout*/:
            return .post
        case .validateToken:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .kakaoLogin(let request):
            return .requestJSONEncodable(request)
//        case .appleLogin(let request):
//            return .requestJSONEncodable(request)
        case .guestLogin(let request):
            return .requestJSONEncodable(request)
        case .refreshToken(let request):
            return .requestJSONEncodable(request)
        case .validateToken:
            return .requestPlain
//        case .logout:
//            return .requestPlain
        }
    }
}
