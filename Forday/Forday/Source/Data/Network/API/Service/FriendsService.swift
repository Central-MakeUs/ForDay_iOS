//
//  FriendsService.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import Foundation
import Moya

final class FriendsService {

    private let provider: MoyaProvider<FriendsTarget>

    init(provider: MoyaProvider<FriendsTarget> = NetworkProvider.createProvider()) {
        self.provider = provider
    }

    // MARK: - 사용자 차단

    /// 사용자를 차단합니다.
    ///
    /// - Parameter userId: 차단할 사용자 ID
    /// - Returns: 차단 결과
    /// - Throws:
    ///   - `USER_NOT_FOUND` (404): 존재하지 않는 사용자
    ///   - `CANNOT_BLOCK_SELF` (400): 자기 자신을 차단하려는 경우
    func blockUser(userId: String) async throws -> DTO.BlockUserResponse {
        let request = DTO.BlockUserRequest(userId: userId)
        return try await provider.request(.blockUser(request: request))
    }

    // MARK: - 사용자 신고

    /// 사용자를 신고합니다.
    ///
    /// - Parameters:
    ///   - userId: 신고할 사용자 ID
    ///   - reason: 신고 사유
    /// - Returns: 신고 결과
    /// - Throws:
    ///   - `USER_NOT_FOUND` (404): 존재하지 않는 사용자
    ///   - `CANNOT_REPORT_SELF` (400): 자기 자신을 신고하려는 경우
    func reportUser(userId: String, reason: String) async throws -> DTO.ReportUserResponse {
        let request = DTO.ReportUserRequest(userId: userId, reason: reason)
        return try await provider.request(.reportUser(request: request))
    }
}
