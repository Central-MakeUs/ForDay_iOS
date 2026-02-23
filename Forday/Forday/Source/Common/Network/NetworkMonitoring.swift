//
//  NetworkMonitoring.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import Foundation

/// 네트워크 모니터링 프로토콜 (DI용)
protocol NetworkMonitoring {
    /// 네트워크 연결 상태
    var isNetworkReachable: Bool { get }

    /// 네트워크 모니터링 시작
    func startMonitoring()

    /// 네트워크 모니터링 중지
    func stopMonitoring()

    /// 서버 상태 확인 (Health Check)
    func checkServerHealth() async -> Bool

    /// 네트워크 및 서버 상태 전체 확인
    func checkConnectivity() async -> (network: Bool, server: Bool)
}
