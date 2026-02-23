//
//  NetworkMonitor.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import Foundation
import Network

/// 네트워크 상태 모니터링 및 서버 헬스체크
final class NetworkMonitor: NetworkMonitoring {

    // MARK: - Properties

    private let pathMonitor: NWPathMonitor
    private let monitorQueue: DispatchQueue
    private let authService: AuthService

    private var _currentPath: NWPath?
    private let pathLock = NSLock()

    private var currentPath: NWPath? {
        get {
            pathLock.lock()
            defer { pathLock.unlock() }
            return _currentPath
        }
        set {
            pathLock.lock()
            defer { pathLock.unlock() }
            _currentPath = newValue
        }
    }

    /// 네트워크 연결 상태
    var isNetworkReachable: Bool {
        return currentPath?.status == .satisfied
    }

    // MARK: - Initialization

    init(
        pathMonitor: NWPathMonitor = NWPathMonitor(),
        authService: AuthService = AuthService()
    ) {
        self.pathMonitor = pathMonitor
        self.monitorQueue = DispatchQueue(label: "com.forday.networkMonitor")
        self.authService = authService
    }

    // MARK: - Public Methods

    /// 네트워크 모니터링 시작
    func startMonitoring() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.currentPath = path
            self?.handleNetworkStatusChange(path)
        }
        pathMonitor.start(queue: monitorQueue)
    }

    /// 네트워크 모니터링 중지
    func stopMonitoring() {
        pathMonitor.cancel()
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

    private func handleNetworkStatusChange(_ path: NWPath) {
        switch path.status {
        case .satisfied:
            if path.usesInterfaceType(.cellular) {
                print("🟡 [NetworkMonitor] 셀룰러 연결")
            } else if path.usesInterfaceType(.wifi) {
                print("🟢 [NetworkMonitor] WiFi 연결")
            } else if path.usesInterfaceType(.wiredEthernet) {
                print("🟢 [NetworkMonitor] 유선 연결")
            } else {
                print("🟢 [NetworkMonitor] 네트워크 연결됨")
            }
        case .unsatisfied:
            print("🔴 [NetworkMonitor] 네트워크 연결 없음")
        case .requiresConnection:
            print("⚪ [NetworkMonitor] 연결 대기 중")
        @unknown default:
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
