//
//  AIRecommendationResponse.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation

extension DTO {
    
    // Response
    struct AIRecommendationResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: AIRecommendationData
        
        struct AIRecommendationData: Codable {
            let message: String
            let aiCallCount: Int
            let aiCallLimit: Int
            let activities: [ActivityData]
            
            struct ActivityData: Codable {
                let activityId: Int
                let topic: String
                let content: String
                let description: String
            }
        }
        
        func toDomain() -> AIRecommendationResult {
            return AIRecommendationResult(
                message: data.message,
                aiCallCount: data.aiCallCount,
                aiCallLimit: data.aiCallLimit,
                activities: data.activities.map { activity in
                    AIRecommendation(
                        activityId: activity.activityId,
                        topic: activity.topic,
                        content: activity.content,
                        description: activity.description
                    )
                }
            )
        }
    }
}
