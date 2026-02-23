//
//  NetworkConfiguration.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import Foundation

/// 네트워크 설정 상수
enum NetworkConfiguration {

    // MARK: - Timeout

    /// 요청 타임아웃 (초) - 서버 응답 대기 시간
    static let requestTimeout: TimeInterval = 15

    /// 리소스 타임아웃 (초) - 전체 리소스 로딩 시간
    static let resourceTimeout: TimeInterval = 30

    // MARK: - Retry

    /// 최대 재시도 횟수
    static let maxRetryCount: Int = 3

    /// 재시도 간격 (초)
    static let retryDelay: TimeInterval = 1.0

    /// 재시도 대상 HTTP 상태 코드
    static let retryableStatusCodes: Set<Int> = [408, 500, 502, 503, 504]

    /// 재시도 대상 에러 코드 (URLError)
    static let retryableErrorCodes: Set<Int> = [
        URLError.timedOut.rawValue,
        URLError.cannotConnectToHost.rawValue,
        URLError.networkConnectionLost.rawValue,
        URLError.notConnectedToInternet.rawValue
    ]
}
