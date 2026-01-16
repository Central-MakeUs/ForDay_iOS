//
//  FetchHomeInfoUseCase.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

final class FetchHomeInfoUseCase {

    private let repository: HobbyRepositoryInterface

    init(repository: HobbyRepositoryInterface = HobbyRepository()) {
        self.repository = repository
    }

    func execute(hobbyId: Int? = nil) async throws -> HomeInfo {
        return try await repository.fetchHomeInfo(hobbyId: hobbyId)
    }
}
