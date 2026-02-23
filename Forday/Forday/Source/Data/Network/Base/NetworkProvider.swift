//
//  NetworkProvider.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation
import Moya
import Alamofire

/// 공통 MoyaProvider Factory
struct NetworkProvider {

    // MARK: - Session Configuration

    /// Timeout이 설정된 URLSessionConfiguration 생성
    private static func createSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = NetworkConfiguration.requestTimeout
        configuration.timeoutIntervalForResource = NetworkConfiguration.resourceTimeout
        return configuration
    }

    // MARK: - Provider Factory

    /// TokenRefreshInterceptor + RetryPolicy가 적용된 MoyaProvider 생성
    static func createProvider<Target: TargetType>() -> MoyaProvider<Target> {
        let tokenInterceptor = TokenRefreshInterceptor()
        let retryPolicy = NetworkRetryPolicy()

        // TokenRefreshInterceptor는 Adapter + Retrier 역할
        // NetworkRetryPolicy는 추가 Retrier 역할
        let interceptor = Interceptor(
            adapters: [tokenInterceptor],
            retriers: [tokenInterceptor, retryPolicy]
        )

        let session = Session(
            configuration: createSessionConfiguration(),
            interceptor: interceptor
        )

        return MoyaProvider<Target>(
            session: session,
            plugins: [MoyaLoggingPlugin()]
        )
    }

    /// Interceptor 없는 일반 MoyaProvider (Auth API용)
    /// - Note: Auth API는 토큰 갱신 불필요, Retry만 적용
    static func createAuthProvider<Target: TargetType>() -> MoyaProvider<Target> {
        // RequestRetrier를 Interceptor로 래핑
        let interceptor = Interceptor(
            adapters: [],
            retriers: [NetworkRetryPolicy()]
        )

        let session = Session(
            configuration: createSessionConfiguration(),
            interceptor: interceptor
        )

        return MoyaProvider<Target>(
            session: session,
            plugins: [MoyaLoggingPlugin()]
        )
    }
}
