//
//  FetchMyActivitiesUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchMyActivitiesUseCase {

    private let repository: UsersRepositoryInterface

    init(repository: UsersRepositoryInterface = UsersRepository()) {
        self.repository = repository
    }

    /// 사용자 활동 피드 조회 (userId가 nil이면 본인)
    func execute(hobbyIds: [Int], lastRecordId: Int? = nil, size: Int = 24, userId: String? = nil) async throws -> FeedResult {
        return try await repository.fetchFeeds(hobbyIds: hobbyIds, lastRecordId: lastRecordId, feedSize: size, userId: userId)
    }
}
