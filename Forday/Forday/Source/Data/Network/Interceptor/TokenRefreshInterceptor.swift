//
//  TokenRefreshInterceptor.swift
//  Forday
//
//  Created by Claude on 1/17/26.
//

import Foundation
import Alamofire
import UIKit

final class TokenRefreshInterceptor: RequestInterceptor {

    private let tokenStorage = TokenStorage.shared
    private let authService = AuthService()

    // 토큰 재발급 중 중복 요청 방지
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []

    // MARK: - Adapt (Request 전송 전)

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest

        // AccessToken을 헤더에 추가
        if let token = try? tokenStorage.loadAccessToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        completion(.success(urlRequest))
    }

    // MARK: - Retry (Response 받은 후)

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            // 401이 아니면 재시도 안 함
            completion(.doNotRetryWithError(error))
            return
        }

        // DataRequest로 캐스팅하여 응답 데이터 가져오기
        guard let dataRequest = request as? DataRequest,
              let data = dataRequest.data,
              let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) else {
            // 에러 응답 파싱 실패 - 기본적으로 재발급 시도
            refreshTokenAndRetry(completion: completion)
            return
        }

        let errorClassName = errorResponse.data.errorClassName

        switch errorClassName {
        case "TOKEN_EXPIRED", "INVALID_TOKEN":
            // 토큰 재발급 시도
            refreshTokenAndRetry(completion: completion)

        case "LOGIN_EXPIRED":
            // refreshToken 만료 - 로그아웃 처리
            handleLogout()
            completion(.doNotRetryWithError(TokenError.loginExpired))

        default:
            completion(.doNotRetryWithError(error))
        }
    }

    // MARK: - Private Methods

    private func refreshTokenAndRetry(completion: @escaping (RetryResult) -> Void) {
        // 이미 재발급 중이면 대기열에 추가
        guard !isRefreshing else {
            requestsToRetry.append(completion)
            return
        }

        isRefreshing = true

        Task {
            do {
                // refreshToken 가져오기
                let refreshToken = try tokenStorage.loadRefreshToken()

                // 토큰 재발급 요청
                let request = DTO.TokenRefreshRequest(refreshToken: refreshToken)
                let response = try await authService.refreshToken(request: request)

                // 새로운 토큰 저장
                try tokenStorage.saveTokens(
                    accessToken: response.data.accessToken,
                    refreshToken: response.data.refreshToken
                )

                print("✅ 토큰 재발급 성공")

                // 대기 중인 모든 요청 재시도
                requestsToRetry.forEach { $0(.retry) }
                requestsToRetry.removeAll()
                completion(.retry)

            } catch {
                print("❌ 토큰 재발급 실패: \(error)")

                // 재발급 실패 시 로그아웃
                handleLogout()

                // 대기 중인 모든 요청 실패 처리
                requestsToRetry.forEach { $0(.doNotRetryWithError(TokenError.loginExpired)) }
                requestsToRetry.removeAll()
                completion(.doNotRetryWithError(TokenError.loginExpired))
            }

            isRefreshing = false
        }
    }

    private func handleLogout() {
        // 토큰 삭제
        try? tokenStorage.deleteAllTokens()

        // 메인 스레드에서 로그인 화면으로 전환
        DispatchQueue.main.async {
            self.navigateToLogin()
        }
    }

    private func navigateToLogin() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }

        sceneDelegate.showLoginScreen()
    }
}

// MARK: - Error Response Model

private struct ErrorResponse: Decodable {
    let status: Int
    let success: Bool
    let data: ErrorData
}

private struct ErrorData: Decodable {
    let errorClassName: String
    let message: String
}

// MARK: - Token Error

enum TokenError: Error {
    case tokenExpired
    case invalidToken
    case loginExpired
    case unknown
}
