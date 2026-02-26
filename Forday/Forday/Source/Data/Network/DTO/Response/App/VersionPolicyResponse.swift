//
//  VersionPolicyResponse.swift
//  Forday
//
//  Created by Subeen on 2/25/26.
//

import Foundation

extension DTO {

    struct VersionPolicyResponse: Codable {
        let status: Int
        let success: Bool
        let data: VersionPolicyData
    }

    struct VersionPolicyData: Codable {
        let policyVersion: Int
        let platform: String
        let current: VersionInfo
        let minSupported: VersionInfo
        let latest: VersionInfo
        let update: UpdateType
        let storeUrl: String
        let message: String?
    }

    struct VersionInfo: Codable {
        let version: String
        let build: Int
    }

    enum UpdateType: String, Codable {
        case none = "NONE"
        case recommend = "RECOMMEND"
        case force = "FORCE"
        case block = "BLOCK"
    }
}

// MARK: - Domain Mapping

extension DTO.VersionPolicyResponse {
    func toDomain() -> VersionPolicy {
        return VersionPolicy(
            policyVersion: data.policyVersion,
            platform: data.platform,
            currentVersion: data.current.version,
            currentBuild: data.current.build,
            minSupportedVersion: data.minSupported.version,
            minSupportedBuild: data.minSupported.build,
            latestVersion: data.latest.version,
            latestBuild: data.latest.build,
            updateType: data.update.toDomain(),
            storeUrl: data.storeUrl,
            message: data.message
        )
    }
}

extension DTO.UpdateType {
    func toDomain() -> VersionPolicy.UpdateType {
        switch self {
        case .none:
            return .none
        case .recommend:
            return .recommend
        case .force:
            return .force
        case .block:
            return .block
        }
    }
}
