//
//  VersionPolicy.swift
//  Forday
//
//  Created by Subeen on 2/25/26.
//

import Foundation

struct VersionPolicy {
    let policyVersion: Int
    let platform: String
    let currentVersion: String
    let currentBuild: Int
    let minSupportedVersion: String
    let minSupportedBuild: Int
    let latestVersion: String
    let latestBuild: Int
    let updateType: UpdateType
    let storeUrl: String
    let message: String?

    enum UpdateType {
        case none       // 업데이트 불필요
        case recommend  // 권장 업데이트
        case force      // 강제 업데이트
        case block      // 서비스 점검
    }
}
