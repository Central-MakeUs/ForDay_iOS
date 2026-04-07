//
//  AppleLoginUseCase.swift
//  Forday
//
//  Created by Subeen on 2/4/26.
//


import Foundation
import UIKit
import FirebaseMessaging

struct AppleLoginUseCase {

    private let appleAuthService: AppleAuthService
    private let authRepository: AuthRepositoryInterface
    private let tokenStorage: TokenStorage

    init(
        appleAuthService: AppleAuthService = AppleAuthService(),
        authRepository: AuthRepositoryInterface,
        tokenStorage: TokenStorage = TokenStorage.shared
    ) {
        self.appleAuthService = appleAuthService
        self.authRepository = authRepository
        self.tokenStorage = tokenStorage
    }

    // MARK: - Execute

    func execute() async throws -> AuthToken {
        // 1. Apple SDK로 authorization_code 받기
        let authorizationCode = try await appleAuthService.login()

        // 2. FCM 토큰 및 기기 ID 가져오기
        // FCM 토큰 획득 우선순위:
        // 1) 로컬 스토리지에 저장된 토큰 (이전 로그인 시 저장)
        // 2) Firebase에서 현재 발급된 토큰
        // 3) 둘 다 없으면 에러 throw (서버에서 fcmToken 필수 요구)
        guard let fcmToken = FCMTokenStorage.shared.loadFCMToken() ?? Messaging.messaging().fcmToken else {
            throw AppError.auth(.fcmTokenNotAvailable)
        }
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""

        // 3. authorization_code 및 FCM 정보를 서버에 보내서 우리 서버 토큰 받기
        let authToken = try await authRepository.loginWithApple(
            appleIdentityToken: authorizationCode,
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
