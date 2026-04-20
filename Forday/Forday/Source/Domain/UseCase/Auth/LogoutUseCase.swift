//
//  LogoutUseCase.swift
//  Forday
//
//  Created by Subeen on 4/20/26.
//

import Foundation

struct LogoutUseCase {

    private let authRepository: AuthRepositoryInterface
    private let tokenStorage: TokenStorage

    init(
        authRepository: AuthRepositoryInterface = AuthRepository(),
        tokenStorage: TokenStorage = TokenStorage.shared
    ) {
        self.authRepository = authRepository
        self.tokenStorage = tokenStorage
    }

    // MARK: - Execute

    /// 로그아웃 실행
    /// 1. 서버에 로그아웃 API 호출 (서버에서 FCM 토큰 삭제)
    /// 2. 로컬 인증 토큰 삭제 (Access Token, Refresh Token, Guest User ID)
    /// 3. FCM 토큰/Device ID는 유지 (재로그인 시 재사용)
    func execute() async throws {
        print("🔴 LogoutUseCase - 로그아웃 시작")

        // 1. 서버에 로그아웃 API 호출
        try await authRepository.logout()
        print("🔴 LogoutUseCase - 서버 로그아웃 완료")

        // 2. 로컬 인증 토큰 삭제 (Keychain)
        try tokenStorage.deleteAllTokens()
        print("🔴 LogoutUseCase - 로컬 토큰 삭제 완료")

        // 3. FCM 토큰/Device ID는 유지 (UserDefaults)
        // → 삭제하지 않음! 재로그인 시 동일한 토큰 재사용
        print("🔴 LogoutUseCase - 로그아웃 완료")
    }
}
