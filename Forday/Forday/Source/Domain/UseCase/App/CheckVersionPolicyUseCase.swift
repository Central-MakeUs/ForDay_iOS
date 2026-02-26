//
//  CheckVersionPolicyUseCase.swift
//  Forday
//
//  Created by Subeen on 2/25/26.
//

import Foundation

final class CheckVersionPolicyUseCase {

    private let repository: AppRepositoryInterface

    init(repository: AppRepositoryInterface = AppRepository()) {
        self.repository = repository
    }

    /// 앱 버전 정책을 조회합니다.
    /// - Returns: 버전 정책 정보. 실패 시 nil 반환 (앱 사용 계속 허용)
    func execute() async -> VersionPolicy? {
        do {
            let appVersion = Bundle.main.appVersion
            let buildNumber = Bundle.main.buildNumber

            let policy = try await repository.fetchVersionPolicy(
                platform: "IOS",
                appVersion: appVersion,
                build: buildNumber
            )
            return policy
        } catch {
            print("🔴 버전 정책 조회 실패 (앱 사용 계속 허용): \(error)")
            return nil
        }
    }
}

// MARK: - Bundle Extension

private extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var buildNumber: Int {
        guard let buildString = infoDictionary?["CFBundleVersion"] as? String,
              let build = Int(buildString) else {
            return 1
        }
        return build
    }
}
