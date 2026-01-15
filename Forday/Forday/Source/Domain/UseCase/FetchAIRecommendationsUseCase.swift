//
//  FetchAIRecommendationsUseCase.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation

struct FetchAIRecommendationsUseCase {
    
    private let activityRepository: ActivityRepositoryInterface
    
    init(activityRepository: ActivityRepositoryInterface = ActivityRepository()) {
        self.activityRepository = activityRepository
    }
    
    func execute(hobbyId: Int) async throws -> AIRecommendationResult {
        return try await activityRepository.fetchAIRecommendations(hobbyId: hobbyId)
    }
}