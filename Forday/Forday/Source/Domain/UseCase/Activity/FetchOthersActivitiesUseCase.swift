//
//  FetchOthersActivitiesUseCase.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

final class FetchOthersActivitiesUseCase {

    private let repository: ActivityRepositoryInterface

    init(repository: ActivityRepositoryInterface = ActivityRepository()) {
        self.repository = repository
    }

    func execute(hobbyId: Int) async throws -> OthersActivityResult {
        return try await repository.fetchOthersActivities(hobbyId: hobbyId)
    }
}
