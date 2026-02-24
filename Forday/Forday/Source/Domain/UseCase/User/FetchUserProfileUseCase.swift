//
//  FetchUserProfileUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchUserProfileUseCase {

    private let repository: UsersRepositoryInterface

    init(repository: UsersRepositoryInterface = UsersRepository()) {
        self.repository = repository
    }

    /// 사용자 정보 조회 (userId가 nil이면 본인)
    func execute(userId: String? = nil) async throws -> UserInfo {
        return try await repository.fetchUserInfo(userId: userId)
    }
}
