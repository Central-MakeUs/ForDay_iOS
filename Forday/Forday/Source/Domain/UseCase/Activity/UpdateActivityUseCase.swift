//
//  UpdateActivityUseCase.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation

final class UpdateActivityUseCase {
    
    private let repository: ActivityRepositoryInterface
    
    init(repository: ActivityRepositoryInterface = ActivityRepository()) {
        self.repository = repository
    }
    
    func execute(activityId: Int, content: String) async throws -> String {
        return try await repository.updateActivity(activityId: activityId, content: content)
    }
}