//
//  AutoLoginUseCase.swift
//  Forday
//
//  Created by Subeen on 2/14/26.
//


import Foundation

/// 자동 로그인 결과
enum AutoLoginResult {
    case success           // 토큰 유효 → 홈 화면으로 이동
    case needsLogin        // 토큰 없음 또는 만료 → 로그인 화면으로 이동
}

struct AutoLoginUseCase {

    private let authRepository: AuthRepositoryInterface
    private let tokenStorage: TokenStorage

    init(
        authRepository: AuthRepositoryInterface,
        tokenStorage: TokenStorage = TokenStorage.shared
    ) {
        self.authRepository = authRepository
        self.tokenStorage = tokenStorage
    }

    // MARK: - Execute

    func execute() async -> AutoLoginResult {
        // 1. 저장된 accessToken이 있는지 확인
        guard let _ = try? tokenStorage.loadAccessToken() else {
            print("🔴 AutoLoginUseCase - 저장된 accessToken 없음")
            return .needsLogin
        }

        // 2. 토큰 유효성 검사
        do {
            let isValid = try await authRepository.validateToken()

            if isValid {
                print("🟢 AutoLoginUseCase - 토큰 유효함")
                return .success
            } else {
                print("🟡 AutoLoginUseCase - 토큰 유효하지 않음, 재발급 시도")
                return await refreshAndRetry()
            }
        } catch {
            print("🟡 AutoLoginUseCase - 토큰 검증 실패: \(error), 재발급 시도")
            return await refreshAndRetry()
        }
    }

    // MARK: - Private Methods

    private func refreshAndRetry() async -> AutoLoginResult {
        // refreshToken으로 accessToken 재발급 시도
        guard let refreshToken = try? tokenStorage.loadRefreshToken() else {
            print("🔴 AutoLoginUseCase - 저장된 refreshToken 없음")
            clearTokensAndReturn()
            return .needsLogin
        }

        do {
            let authToken = try await authRepository.refreshToken(refreshToken: refreshToken)

            // 새 토큰 저장
            try tokenStorage.saveTokens(
                accessToken: authToken.accessToken,
                refreshToken: authToken.refreshToken
            )

            print("🟢 AutoLoginUseCase - 토큰 재발급 성공")
            return .success

        } catch {
            print("🔴 AutoLoginUseCase - 토큰 재발급 실패: \(error)")
            clearTokensAndReturn()
            return .needsLogin
        }
    }

    private func clearTokensAndReturn() {
        try? tokenStorage.deleteAllTokens()
    }
}
