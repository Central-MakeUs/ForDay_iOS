//
//  AuthAPI.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

enum AuthAPI {
    case refreshToken       /// 토큰 재발급
    case logout             /// 로그아웃
    case kakaoLogin         /// 카카오 로그인
    case appleLogin         /// 애플 로그인
    case guestLogin         /// 게스트 둘러보기 (게스트용 토큰 발급)
    
    var endpoint: String {
        switch self {
        case .refreshToken: return "/auth/refresh"
        case .logout: return "/auth/logout"
        case .kakaoLogin: return "/auth/kakao"
        case .appleLogin: return "/auth/apple"
        case .guestLogin: return "/auth/guest"
        }
    }
}
