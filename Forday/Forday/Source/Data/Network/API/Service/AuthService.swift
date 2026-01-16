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
    
    // MARK: - Kakao Login

    func loginWithKakao(request: DTO.KakaoLoginRequest) async throws -> DTO.LoginResponse {
        return try await provider.request(.kakaoLogin(request: request))
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
}
