//
//  DeleteActivityUseCase.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation

final class DeleteActivityUseCase {
    
    private let repository: ActivityRepositoryInterface
    
    init(repository: ActivityRepositoryInterface = ActivityRepository()) {
        self.repository = repository
    }
    
    func execute(activityId: Int) async throws -> String {
        return try await repository.deleteActivity(activityId: activityId)
    }
}