//
//  FetchReactionTabDataUseCase.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import Foundation

final class FetchReactionTabDataUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(
        recordId: Int,
        reactionType: ReactionType?,
        lastReactionId: Int,
        size: Int = 10
    ) async throws -> ReactionTabData {
        return try await repository.fetchReactionTabData(
            recordId: recordId,
            reactionType: reactionType,
            lastReactionId: lastReactionId,
            size: size
        )
    }
}
