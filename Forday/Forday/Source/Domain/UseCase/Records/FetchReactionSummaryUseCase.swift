//
//  FetchReactionSummaryUseCase.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import Foundation

final class FetchReactionSummaryUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(
        recordId: Int,
        size: Int = 20
    ) async throws -> ReactionSummaryResponse {
        return try await repository.fetchReactionSummary(
            recordId: recordId,
            size: size
        )
    }
}
