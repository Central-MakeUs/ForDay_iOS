//
//  AuthAPI.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

enum AuthAPI {
    case healthCheck        /// 서버 상태 확인
    case authValidate       /// 토큰 유효성 검사
    case refreshToken       /// 토큰 재발급
    case logout             /// 로그아웃
    case kakaoLogin         /// 카카오 로그인
    case appleLogin         /// 애플 로그인
    case guestLogin         /// 게스트 둘러보기 (게스트용 토큰 발급)
    case switchAccount      /// 게스트 → 소셜 로그인 전환
    case withdraw           /// 회원 탈퇴

    var endpoint: String {
        switch self {
        case .healthCheck: return "/health_check"
        case .authValidate: return "/auth/validate"
        case .refreshToken: return "/auth/refresh"
        case .logout: return "/auth/logout"
        case .kakaoLogin: return "/auth/kakao"
        case .appleLogin: return "/auth/apple"
        case .guestLogin: return "/auth/guest"
        case .switchAccount: return "/auth/switch-account"
        case .withdraw: return "/auth/withdraw"
        }
    }
}
