//
//  AuthRepository.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

final class AuthRepository: AuthRepositoryInterface {
    
    private let apiService: AuthService
    
    init(apiService: AuthService = AuthService()) {
        self.apiService = apiService
    }
    
    // MARK: - Kakao Login
    
    func loginWithKakao(kakaoAccessToken: String, fcmToken: String, deviceId: String) async throws -> AuthToken {
        let request = DTO.KakaoLoginRequest(
            kakaoAccessToken: kakaoAccessToken,
            fcmToken: fcmToken,
            deviceId: deviceId
        )
        let response = try await apiService.loginWithKakao(request: request)
        return response.data.toDomain()
    }
    
    // MARK: - Apple Login

    func loginWithApple(appleIdentityToken: String) async throws -> AuthToken {
        let request = DTO.AppleLoginRequest(code: appleIdentityToken)
        let response = try await apiService.loginWithApple(request: request)
        return response.data.toDomain()
    }
    
    // MARK: - Guest Login
    
    func loginAsGuest(guestUserId: String?) async throws -> AuthToken {
        let request = DTO.GuestLoginRequest(guestUserId: guestUserId)
        let response = try await apiService.loginAsGuest(request: request)
        return response.data.toDomain()
    }
    
    // MARK: - Validate Token

    func validateToken() async throws -> Bool {
        let response = try await apiService.validateToken()
        return response.data.tokenValid
    }

    // MARK: - Refresh Token

    func refreshToken(refreshToken: String) async throws -> AuthToken {
        let request = DTO.TokenRefreshRequest(refreshToken: refreshToken)
        let response = try await apiService.refreshToken(request: request)

        // 토큰 재발급 API는 accessToken, refreshToken만 반환
        // 나머지 필드는 사용되지 않음 (AutoLoginUseCase에서 토큰만 저장)
        // socialType 등 다른 필드가 필요한 경우 별도 API 호출 필요
        return AuthToken(
            accessToken: response.data.accessToken,
            refreshToken: response.data.refreshToken,
            isNewUser: false,
            socialType: .guest,  // placeholder - 실제 사용되지 않음
            guestUserId: nil,
            onboardingCompleted: true,
            nicknameSet: true,
            onboardingData: nil,
            termsConsentCompleted: true  // 토큰 재발급은 이미 약관 동의한 상태
        )
    }
    
    // MARK: - Logout

    func logout() async throws {
        // TODO: 나중에 구현
        fatalError("Logout not implemented yet")
    }

    // MARK: - Switch Account (Guest → Social)

    func switchAccount(socialType: SocialType, socialCode: String) async throws -> AuthToken {
        let request = DTO.SwitchAccountRequest(socialType: socialType.rawValue, socialCode: socialCode)
        let response = try await apiService.switchAccount(request: request)
        return response.data.toDomain()
    }
}
n()
    }
}
