//
//  ActivityRepository.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation

final class ActivityRepository: ActivityRepositoryInterface {
    
    private let activityService: ActivityService
    
    init(activityService: ActivityService = ActivityService()) {
        self.activityService = activityService
    }
    
    func fetchAIRecommendations(hobbyId: Int) async throws -> AIRecommendationResult {
        let response = try await activityService.fetchAIRecommendations(hobbyId: hobbyId)
        return response.toDomain()
    }
}
