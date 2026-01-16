//
//  FetchActivityListUseCase.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation

final class FetchActivityListUseCase {
    
    private let repository: ActivityRepositoryInterface
    
    init(repository: ActivityRepositoryInterface = ActivityRepository()) {
        self.repository = repository
    }
    
    func execute(hobbyId: Int) async throws -> [Activity] {
        return try await repository.fetchActivityList(hobbyId: hobbyId)
    }
}