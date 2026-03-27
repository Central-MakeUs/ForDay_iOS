//
//  FetchHobbyChipsUseCase.swift
//  Forday
//
//  Created by Subeen on 3/26/26.
//

import Foundation

final class FetchHobbyChipsUseCase {

    private let repository: HobbyRepositoryInterface

    init(repository: HobbyRepositoryInterface = HobbyRepository()) {
        self.repository = repository
    }

    func execute(status: String = "IN_PROGRESS") async throws -> [HobbyChip] {
        return try await repository.fetchHobbyChips(status: status)
    }
}
