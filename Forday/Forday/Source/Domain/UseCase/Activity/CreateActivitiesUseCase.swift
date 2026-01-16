//
//  CreateActivitiesUseCase.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation

final class CreateActivitiesUseCase {
    
    private let repository: ActivityRepositoryInterface
    
    init(repository: ActivityRepositoryInterface = ActivityRepository()) {
        self.repository = repository
    }
    
    func execute(hobbyId: Int, activities: [ActivityInput]) async throws -> String {
        return try await repository.createActivities(hobbyId: hobbyId, activities: activities)
    }
}