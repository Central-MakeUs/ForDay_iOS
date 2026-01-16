//
//  NetworkProvider.swift
//  Forday
//
//  Created by Claude on 1/17/26.
//

import Foundation
import Moya
import Alamofire

/// 공통 MoyaProvider Factory
struct NetworkProvider {

    /// TokenRefreshInterceptor가 적용된 MoyaProvider 생성
    static func createProvider<Target: TargetType>() -> MoyaProvider<Target> {
        // Alamofire Session with Interceptor
        let session = Session(interceptor: TokenRefreshInterceptor())

        // MoyaProvider with custom session
        return MoyaProvider<Target>(
            session: session,
            plugins: [MoyaLoggingPlugin()]
        )
    }

    /// Interceptor 없는 일반 MoyaProvider (Auth API용)
    static func createAuthProvider<Target: TargetType>() -> MoyaProvider<Target> {
        return MoyaProvider<Target>(
            plugins: [MoyaLoggingPlugin()]
        )
    }
}
