//
//  SwitchToAppleUseCase.swift
//  Forday
//
//  Created by Subeen on 2/4/26.
//

import Foundation
import UIKit
import FirebaseMessaging

struct SwitchToAppleUseCase {

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
        let fcmToken = Messaging.messaging().fcmToken ?? ""
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""

        // 3. authorization_code 및 FCM 정보를 서버에 보내서 계정 전환
        let authToken = try await authRepository.switchAccount(
            socialType: .apple,
            socialCode: authorizationCode,
            fcmToken: fcmToken,
            deviceId: deviceId
        )

        // 4. 새로운 토큰을 KeyChain에 저장
        try tokenStorage.saveTokens(
            accessToken: authToken.accessToken,
            refreshToken: authToken.refreshToken
        )

        // 5. 게스트 ID 삭제 (더 이상 게스트가 아님)
        try tokenStorage.deleteGuestUserId()

        // 6. 전체 AuthToken 반환
        return authToken
    }
}
