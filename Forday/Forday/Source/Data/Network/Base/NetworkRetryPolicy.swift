//
//  NetworkRetryPolicy.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import Foundation
import Alamofire

/// 네트워크 요청 재시도 정책
final class NetworkRetryPolicy: RequestRetrier {

    // MARK: - Properties

    private let maxRetryCount: Int
    private let retryDelay: TimeInterval
    private let retryableStatusCodes: Set<Int>
    private let retryableErrorCodes: Set<Int>

    // MARK: - Initialization

    init(
        maxRetryCount: Int = NetworkConfiguration.maxRetryCount,
        retryDelay: TimeInterval = NetworkConfiguration.retryDelay,
        retryableStatusCodes: Set<Int> = NetworkConfiguration.retryableStatusCodes,
        retryableErrorCodes: Set<Int> = NetworkConfiguration.retryableErrorCodes
    ) {
        self.maxRetryCount = maxRetryCount
        self.retryDelay = retryDelay
        self.retryableStatusCodes = retryableStatusCodes
        self.retryableErrorCodes = retryableErrorCodes
    }

    // MARK: - RequestRetrier

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        let retryCount = request.retryCount

        // 최대 재시도 횟수 초과
        guard retryCount < maxRetryCount else {
            print("🔴 [Retry] 최대 재시도 횟수 초과 (\(maxRetryCount)회)")
            completion(.doNotRetry)
            return
        }

        // 재시도 가능한 에러인지 확인
        guard shouldRetry(error: error, response: request.response) else {
            completion(.doNotRetry)
            return
        }

        // 지수 백오프: 1초 → 2초 → 4초
        let delay = retryDelay * pow(2.0, Double(retryCount))

        print("🔄 [Retry] \(retryCount + 1)/\(maxRetryCount) 재시도 예정 (\(delay)초 후)")
        completion(.retryWithDelay(delay))
    }

    // MARK: - Private Methods

    private func shouldRetry(error: Error, response: HTTPURLResponse?) -> Bool {
        // HTTP 상태 코드 기반 재시도
        if let statusCode = response?.statusCode,
           retryableStatusCodes.contains(statusCode) {
            print("🔄 [Retry] 재시도 가능한 상태 코드: \(statusCode)")
            return true
        }

        // URLError 기반 재시도
        if let urlError = error as? URLError,
           retryableErrorCodes.contains(urlError.errorCode) {
            print("🔄 [Retry] 재시도 가능한 에러: \(urlError.localizedDescription)")
            return true
        }

        // AFError 내부의 URLError 확인
        if let afError = error as? AFError,
           case .sessionTaskFailed(let underlyingError) = afError,
           let urlError = underlyingError as? URLError,
           retryableErrorCodes.contains(urlError.errorCode) {
            print("🔄 [Retry] 재시도 가능한 세션 에러: \(urlError.localizedDescription)")
            return true
        }

        return false
    }
}
