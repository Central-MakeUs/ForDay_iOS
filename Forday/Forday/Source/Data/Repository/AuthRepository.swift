//
//  AuthRepository.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

final class AuthRepository: AuthRepositoryInterface {
    
    private let apiService: AuthAPIService
    
    init(apiService: AuthAPIService = AuthAPIService()) {
        self.apiService = apiService
    }
    
    // MARK: - Kakao Login
    
    func loginWithKakao(kakaoAccessToken: String) async throws -> AuthToken {
        let request = DTO.KakaoLoginRequest(kakaoAccessToken: kakaoAccessToken)
        let response = try await apiService.loginWithKakao(request: request)
        return response.toDomain()
    }
    
    // MARK: - Apple Login
    
    func loginWithApple(appleIdentityToken: String) async throws -> AuthToken {
        // TODO: 나중에 구현
        fatalError("Apple Login not implemented yet")
    }
    
    // MARK: - Guest Login
    
    func loginAsGuest() async throws -> AuthToken {
        // TODO: 나중에 구현
        fatalError("Guest Login not implemented yet")
    }
    
    // MARK: - Refresh Token
    
    func refreshToken(refreshToken: String) async throws -> AuthToken {
        // TODO: 나중에 구현
        fatalError("Refresh Token not implemented yet")
    }
    
    // MARK: - Logout
    
    func logout() async throws {
        // TODO: 나중에 구현
        fatalError("Logout not implemented yet")
    }
}
