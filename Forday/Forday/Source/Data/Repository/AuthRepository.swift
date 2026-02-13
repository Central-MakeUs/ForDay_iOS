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
    
    func loginWithKakao(kakaoAccessToken: String) async throws -> AuthToken {
        let request = DTO.KakaoLoginRequest(kakaoAccessToken: kakaoAccessToken)
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

        // 토큰 재발급은 accessToken, refreshToken만 반환하므로 나머지는 기본값 설정
        return AuthToken(
            accessToken: response.data.accessToken,
            refreshToken: response.data.refreshToken,
            isNewUser: false,
            socialType: .guest,
            guestUserId: nil,
            onboardingCompleted: true,
            nicknameSet: true,
            onboardingData: nil
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
