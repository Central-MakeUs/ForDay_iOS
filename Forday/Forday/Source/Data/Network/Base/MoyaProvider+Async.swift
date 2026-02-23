//
//  MoyaProvider+Async.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation
import Moya
import UIKit

extension MoyaProvider {

    /// Generic async/await wrapper for Moya requests with automatic JSON decoding and error handling
    /// - Parameter target: The target endpoint to request
    /// - Returns: Decoded response of type T
    /// - Throws: AppError with proper error classification
    func request<T: Decodable>(_ target: Target) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    _Concurrency.Task {
                        do {
                            // 401 에러 처리 - 토큰 재발급 시도
                            if response.statusCode == 401 {
                                let result: Result<T, Error> = await self.handleUnauthorized(
                                    response: response,
                                    target: target
                                )
                                switch result {
                                case .success(let decoded):
                                    continuation.resume(returning: decoded)
                                case .failure(let error):
                                    continuation.resume(throwing: error)
                                }
                                return
                            }

                            // Check if response is an error (4xx, 5xx)
                            if (400...599).contains(response.statusCode) {
                                // Try to parse server error
                                if let serverError = try? response.map(ServerErrorResponse.self) {
                                    continuation.resume(throwing: AppError.server(serverError.toServerError()))
                                    return
                                }
                            }

                            // Try to decode success response
                            let decoded = try response.map(T.self)
                            continuation.resume(returning: decoded)

                        } catch let decodingError as DecodingError {
                            print("❌ Decoding Error: \(decodingError)")
                            continuation.resume(throwing: AppError.decoding(decodingError))

                        } catch {
                            continuation.resume(throwing: AppError.unknown(error))
                        }
                    }

                case .failure(let error):
                    // Convert MoyaError to AppError
                    let appError = self.convertMoyaError(error)
                    continuation.resume(throwing: appError)
                }
            }
        }
    }

    // MARK: - 401 Unauthorized 처리

    /// 401 에러 시 토큰 재발급 후 재시도
    private func handleUnauthorized<T: Decodable>(
        response: Response,
        target: Target
    ) async -> Result<T, Error> {
        // 에러 응답 파싱
        guard let errorResponse = try? response.map(TokenErrorResponse.self) else {
            // 파싱 실패 시 토큰 재발급 시도
            return await refreshAndRetry(target: target)
        }

        let errorClassName = errorResponse.data.errorClassName

        switch errorClassName {
        case "TOKEN_EXPIRED", "INVALID_TOKEN":
            // Access Token 만료 → 토큰 재발급 시도
            print("🔄 토큰 만료 감지 - 재발급 시도")
            return await refreshAndRetry(target: target)

        case "LOGIN_EXPIRED":
            // Refresh Token 만료 → 로그아웃
            print("❌ 로그인 만료 - 로그아웃 처리")
            handleLogout()
            return .failure(AppError.auth(.loginExpired))

        default:
            // 기타 401 에러
            return .failure(AppError.auth(.unauthorized))
        }
    }

    /// 토큰 재발급 후 원래 요청 재시도
    private func refreshAndRetry<T: Decodable>(target: Target) async -> Result<T, Error> {
        do {
            // 토큰 재발급
            try await TokenRefreshManager.shared.refreshTokenIfNeeded()
            print("✅ 토큰 재발급 성공 - 요청 재시도")

            // 원래 요청 재시도
            let result: T = try await request(target)
            return .success(result)

        } catch {
            print("❌ 토큰 재발급 실패: \(error)")
            // 재발급 실패 시 로그아웃
            handleLogout()
            return .failure(AppError.auth(.loginExpired))
        }
    }

    /// 로그아웃 처리
    @MainActor
    private func handleLogout() {
        // 토큰 삭제
        try? TokenStorage.shared.deleteAllTokens()

        // 로그인 화면으로 전환
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }

        sceneDelegate.showLoginScreen()
    }

    /// Convert MoyaError to AppError
    private func convertMoyaError(_ error: MoyaError) -> AppError {
        switch error {
        case .underlying(let nsError, _):
            let urlError = nsError as? URLError
            switch urlError?.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .network(.noInternet)
            case .timedOut:
                return .network(.timeout)
            case .cancelled:
                return .network(.cancelled)
            default:
                return .network(.unknown)
            }

        default:
            return .unknown(error)
        }
    }
}

// MARK: - Token Error Response

private struct TokenErrorResponse: Decodable {
    let status: Int
    let success: Bool
    let data: TokenErrorData
}

private struct TokenErrorData: Decodable {
    let errorClassName: String
    let message: String
}
