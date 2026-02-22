//
//  TokenRefreshManager.swift
//  Forday
//
//  Created by Subeen on 2/22/26.
//

import Foundation

/// 토큰 재발급을 중앙에서 관리하는 싱글톤 클래스
/// - 중복 재발급 요청 방지
/// - AuthService를 통한 토큰 재발급
final class TokenRefreshManager {

    static let shared = TokenRefreshManager()

    private let tokenStorage = TokenStorage.shared
    private let authService: AuthService

    // 토큰 재발급 중 중복 요청 방지
    private var isRefreshing = false
    private var refreshTask: Task<Void, Error>?

    private init() {
        // AuthService는 createAuthProvider()를 사용하므로 토큰 헤더 자동 추가 안 됨
        self.authService = AuthService()
    }

    // MARK: - Public Methods

    /// 토큰 재발급 (중복 요청 방지)
    /// - Throws: 재발급 실패 시 에러
    func refreshTokenIfNeeded() async throws {
        // 이미 재발급 중이면 기존 작업 완료 대기
        if let existingTask = refreshTask {
            try await existingTask.value
            return
        }

        // 새 재발급 작업 시작
        let task = Task {
            try await performTokenRefresh()
        }
        refreshTask = task

        do {
            try await task.value
        } catch {
            refreshTask = nil
            throw error
        }

        refreshTask = nil
    }

    // MARK: - Private Methods

    private func performTokenRefresh() async throws {
        guard !isRefreshing else { return }
        isRefreshing = true

        defer { isRefreshing = false }

        // Refresh Token 가져오기
        let refreshToken: String
        do {
            refreshToken = try tokenStorage.loadRefreshToken()
        } catch {
            print("❌ Refresh Token 없음")
            throw TokenRefreshError.noRefreshToken
        }

        // 토큰 재발급 요청 (헤더에 토큰 없이)
        let request = DTO.TokenRefreshRequest(refreshToken: refreshToken)

        do {
            let response = try await authService.refreshToken(request: request)

            // 새 토큰 저장
            try tokenStorage.saveTokens(
                accessToken: response.data.accessToken,
                refreshToken: response.data.refreshToken
            )

            print("✅ 토큰 재발급 완료")

        } catch {
            print("❌ 토큰 재발급 API 실패: \(error)")
            throw TokenRefreshError.refreshFailed
        }
    }
}

// MARK: - Token Refresh Error

enum TokenRefreshError: Error {
    case noRefreshToken
    case refreshFailed
    case loginExpired
}
