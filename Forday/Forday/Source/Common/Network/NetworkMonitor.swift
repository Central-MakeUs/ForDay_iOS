//
//  NetworkMonitor.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import Foundation
import Alamofire

/// 네트워크 상태 모니터링 및 서버 헬스체크
final class NetworkMonitor: NetworkMonitoring {

    // MARK: - Properties

    private let reachabilityManager: NetworkReachabilityManager?
    private let authService: AuthService

    /// 네트워크 연결 상태
    var isNetworkReachable: Bool {
        return reachabilityManager?.isReachable ?? false
    }

    // MARK: - Initialization

    init(
        reachabilityManager: NetworkReachabilityManager? = NetworkReachabilityManager(),
        authService: AuthService = AuthService()
    ) {
        self.reachabilityManager = reachabilityManager
        self.authService = authService
    }

    // MARK: - Public Methods

    /// 네트워크 모니터링 시작
    func startMonitoring() {
        reachabilityManager?.startListening { [weak self] status in
            self?.handleNetworkStatusChange(status)
        }
    }

    /// 네트워크 모니터링 중지
    func stopMonitoring() {
        reachabilityManager?.stopListening()
    }

    /// 서버 상태 확인 (Health Check)
    /// - Returns: 서버가 정상이면 true
    func checkServerHealth() async -> Bool {
        guard isNetworkReachable else {
            print("🔴 네트워크 연결 없음")
            return false
        }

        do {
            let isHealthy = try await authService.healthCheck()
            print(isHealthy ? "🟢 서버 정상" : "🔴 서버 비정상")
            return isHealthy
        } catch {
            print("🔴 서버 연결 실패: \(error.localizedDescription)")
            return false
        }
    }

    /// 네트워크 및 서버 상태 전체 확인
    /// - Returns: (네트워크 연결 여부, 서버 정상 여부)
    func checkConnectivity() async -> (network: Bool, server: Bool) {
        let networkOK = isNetworkReachable
        let serverOK = await checkServerHealth()
        return (networkOK, serverOK)
    }

    // MARK: - Private Methods

    private func handleNetworkStatusChange(_ status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        switch status {
        case .notReachable:
            print("🔴 [NetworkMonitor] 네트워크 연결 없음")
        case .reachable(.cellular):
            print("🟡 [NetworkMonitor] 셀룰러 연결")
        case .reachable(.ethernetOrWiFi):
            print("🟢 [NetworkMonitor] WiFi 연결")
        case .unknown:
            print("⚪ [NetworkMonitor] 네트워크 상태 알 수 없음")
        }
    }
}

// MARK: - Debug Helper

#if DEBUG
extension NetworkMonitor {
    /// 디버그용: 전체 연결 상태 출력
    func printStatus() async {
        let (network, server) = await checkConnectivity()
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 네트워크 상태: \(network ? "✅ 연결됨" : "❌ 연결 안됨")")
        print("🖥️ 서버 상태: \(server ? "✅ 정상" : "❌ 비정상")")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}
#endif
