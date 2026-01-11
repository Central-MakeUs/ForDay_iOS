//
//  KakaoLoginUseCase.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

struct KakaoLoginUseCase {
    
    private let kakaoAuthService: SocialAuthService
    private let authRepository: AuthRepositoryInterface
    private let tokenStorage: TokenStorage
    
    init(
        kakaoAuthService: SocialAuthService = KakaoAuthService(),
        authRepository: AuthRepositoryInterface,
        tokenStorage: TokenStorage = TokenStorage.shared
    ) {
        self.kakaoAuthService = kakaoAuthService
        self.authRepository = authRepository
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Execute
    
    func execute() async throws -> Bool {
        // 1. 카카오 SDK로 카카오 토큰 받기
        let kakaoAccessToken = try await kakaoAuthService.login()
        
        // 2. 카카오 토큰을 서버에 보내서 우리 서버 토큰 받기
        let authToken = try await authRepository.loginWithKakao(kakaoAccessToken: kakaoAccessToken)
        
        // 3. 받은 토큰을 KeyChain에 저장
        try tokenStorage.saveTokens(
            accessToken: authToken.accessToken,
            refreshToken: authToken.refreshToken
        )
        
        // 4. 신규 유저 여부 반환
        return authToken.isNewUser
    }
}