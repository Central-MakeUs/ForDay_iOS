//
//  FetchReactionUsersUseCase.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

final class FetchReactionUsersUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(
        recordId: Int,
        reactionType: ReactionType,
        lastUserId: String? = nil,
        size: Int = 10
    ) async throws -> FetchReactionUsersResult {
        return try await repository.fetchReactionUsers(
            recordId: recordId,
            reactionType: reactionType,
            lastUserId: lastUserId,
            size: size
        )
    }
}
