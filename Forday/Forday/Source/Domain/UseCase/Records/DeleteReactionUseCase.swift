//
//  DeleteReactionUseCase.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import Foundation

final class DeleteReactionUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(recordId: Int, reactionType: ReactionType) async throws -> DeleteReactionResult {
        return try await repository.deleteReaction(recordId: recordId, reactionType: reactionType)
    }
}
