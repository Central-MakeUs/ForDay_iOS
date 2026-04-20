//
//  AuthService.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation
import Moya

final class AuthService {

    private let provider: MoyaProvider<AuthTarget>

    init(provider: MoyaProvider<AuthTarget> = NetworkProvider.createAuthProvider()) {
        self.provider = provider
    }

    // MARK: - Health Check

    /// 서버 상태 확인 (status 200이면 정상)
    func healthCheck() async throws -> Bool {
        let response: DTO.HealthCheckResponse = try await provider.request(.healthCheck)
        return response.status == 200
    }

    // MARK: - Kakao Login

    func loginWithKakao(request: DTO.KakaoLoginRequest) async throws -> DTO.LoginResponse {
        return try await provider.request(.kakaoLogin(request: request))
    }

    // MARK: - Apple Login

    func loginWithApple(request: DTO.AppleLoginRequest) async throws -> DTO.LoginResponse {
        return try await provider.request(.appleLogin(request: request))
    }

    // MARK: - Guest Login

    func loginAsGuest(request: DTO.GuestLoginRequest) async throws -> DTO.LoginResponse {
        return try await provider.request(.guestLogin(request: request))
    }

    // MARK: - Token Refresh

    func refreshToken(request: DTO.TokenRefreshRequest) async throws -> DTO.TokenRefreshResponse {
        return try await provider.request(.refreshToken(request: request))
    }

    // MARK: - Token Validation

    func validateToken() async throws -> DTO.TokenValidateResponse {
        return try await provider.request(.validateToken)
    }

    // MARK: - Switch Account (Guest → Social)

    func switchAccount(request: DTO.SwitchAccountRequest) async throws -> DTO.SwitchAccountResponse {
        return try await provider.request(.switchAccount(request: request))
    }

    // MARK: - Logout

    func logout() async throws -> DTO.LogoutResponse {
        return try await provider.request(.logout)
    }

    // MARK: - Withdraw (회원 탈퇴)

    func withdraw() async throws -> DTO.WithdrawResponse {
        return try await provider.request(.withdraw)
    }
}
