//
//  KakaoLoginUseCase.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation
import UIKit
import FirebaseMessaging

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

    func execute() async throws -> AuthToken {
        // 1. 카카오 SDK로 카카오 토큰 받기
        let kakaoAccessToken = try await kakaoAuthService.login()

        // 2. FCM 토큰 및 기기 ID 가져오기
        let fcmToken = Messaging.messaging().fcmToken ?? ""
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""

        // 3. 카카오 토큰 및 FCM 정보를 서버에 보내서 우리 서버 토큰 받기
        let authToken = try await authRepository.loginWithKakao(
            kakaoAccessToken: kakaoAccessToken,
            fcmToken: fcmToken,
            deviceId: deviceId
        )

        // 4. 받은 토큰을 KeyChain에 저장
        try tokenStorage.saveTokens(
            accessToken: authToken.accessToken,
            refreshToken: authToken.refreshToken
        )

        // 5. 게스트 ID 삭제 (이전에 게스트 로그인 했을 수 있으므로)
        try? tokenStorage.deleteGuestUserId()

        // 6. 전체 AuthToken 반환
        return authToken
    }
}