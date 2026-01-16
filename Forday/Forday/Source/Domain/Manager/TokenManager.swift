//
//  TokenManager.swift
//  Forday
//
//  Created by Claude on 1/17/26.
//

import Foundation

final class TokenManager {

    static let shared = TokenManager()

    private let tokenStorage = TokenStorage.shared
    private let authService = AuthService()

    private init() {}

    // MARK: - Token Validation on App Launch

    /// 앱 시작 시 토큰 유효성 검사
    func validateTokenOnAppLaunch() async -> Bool {
        // 토큰이 없으면 로그인 필요
        guard (try? tokenStorage.loadAccessToken()) != nil else {
            return false
        }

        do {
            // 토큰 유효성 검사 API 호출
            let response = try await authService.validateToken()

            if response.data.tokenValid {
                print("✅ 토큰 유효함")
                return true
            } else {
                print("⚠️ 토큰 무효 - 재발급 시도")
                return await attemptTokenRefresh()
            }

        } catch {
            print("⚠️ 토큰 검증 실패 - 재발급 시도")
            return await attemptTokenRefresh()
        }
    }

    // MARK: - Private Token Refresh

    /// 토큰 재발급 시도
    private func attemptTokenRefresh() async -> Bool {
        do {
            let refreshToken = try tokenStorage.loadRefreshToken()
            let request = DTO.TokenRefreshRequest(refreshToken: refreshToken)
            let response = try await authService.refreshToken(request: request)

            // 새 토큰 저장
            try tokenStorage.saveTokens(
                accessToken: response.data.accessToken,
                refreshToken: response.data.refreshToken
            )

            print("✅ 토큰 재발급 성공")
            return true

        } catch {
            print("❌ 토큰 재발급 실패: \(error)")

            // refreshToken 만료 - 로그아웃 필요
            try? tokenStorage.deleteAllTokens()
            return false
        }
    }
}
