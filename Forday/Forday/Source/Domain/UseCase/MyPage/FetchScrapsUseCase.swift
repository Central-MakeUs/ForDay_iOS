//
//  FetchScrapsUseCase.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

final class FetchScrapsUseCase {

    private let repository: UsersRepositoryInterface

    init(repository: UsersRepositoryInterface = UsersRepository()) {
        self.repository = repository
    }

    func execute(lastRecordId: Int? = nil, size: Int = 24, userId: String? = nil) async throws -> FeedResult {
        return try await repository.fetchScraps(lastRecordId: lastRecordId, feedSize: size, userId: userId)
    }
}
