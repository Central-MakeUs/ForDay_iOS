//
//  AddReactionUseCase.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import Foundation

final class AddReactionUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(recordId: Int, reactionType: ReactionType) async throws -> AddReactionResult {
        return try await repository.addReaction(recordId: recordId, reactionType: reactionType)
    }
}
