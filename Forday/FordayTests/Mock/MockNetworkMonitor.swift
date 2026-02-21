//
//  MockNetworkMonitor.swift
//  FordayTests
//
//  Created by Subeen on 2/21/26.
//

import Foundation
@testable import Forday

/// 테스트용 MockNetworkMonitor
final class MockNetworkMonitor: NetworkMonitoring {

    // MARK: - Configurable Properties

    /// 네트워크 연결 상태 (테스트에서 설정 가능)
    var isNetworkReachable: Bool = true

    /// 서버 상태 (테스트에서 설정 가능)
    var isServerHealthy: Bool = true

    // MARK: - Call Tracking

    /// startMonitoring 호출 횟수
    private(set) var startMonitoringCallCount = 0

    /// stopMonitoring 호출 횟수
    private(set) var stopMonitoringCallCount = 0

    /// checkServerHealth 호출 횟수
    private(set) var checkServerHealthCallCount = 0

    // MARK: - NetworkMonitoring

    func startMonitoring() {
        startMonitoringCallCount += 1
    }

    func stopMonitoring() {
        stopMonitoringCallCount += 1
    }

    func checkServerHealth() async -> Bool {
        checkServerHealthCallCount += 1
        return isServerHealthy
    }

    func checkConnectivity() async -> (network: Bool, server: Bool) {
        let serverOK = await checkServerHealth()
        return (isNetworkReachable, serverOK)
    }

    // MARK: - Helper

    /// 모든 상태 초기화
    func reset() {
        isNetworkReachable = true
        isServerHealthy = true
        startMonitoringCallCount = 0
        stopMonitoringCallCount = 0
        checkServerHealthCallCount = 0
    }
}
