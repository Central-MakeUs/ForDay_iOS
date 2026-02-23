//
//  AIActivityItems.swift
//  Forday
//
//  Created by Subeen on 2/23/26.
//

import Foundation

struct AIActivityItemsResult {
    let message: String
    let hobbyId: Int
    let hobbyName: String
    let activityItems: [AIActivityItem]
}

struct AIActivityItem {
    let itemId: Int
    let content: String
    let description: String
}

// MARK: - Conversion to AIRecommendation

extension AIActivityItem {
    /// AIActivityItem을 AIRecommendation으로 변환
    func toAIRecommendation() -> AIRecommendation {
        return AIRecommendation(
            activityId: itemId,
            topic: content,
            content: content,
            description: description
        )
    }
}

extension AIActivityItemsResult {
    /// AIActivityItemsResult를 AIRecommendationResult로 변환
    /// - Parameter aiCallLimit: AI 호출 제한 (기본값 3)
    func toAIRecommendationResult(aiCallLimit: Int = 3) -> AIRecommendationResult {
        return AIRecommendationResult(
            message: message,
            recommendedText: message,
            aiCallCount: aiCallLimit,  // 호출 횟수 소진됨
            aiCallLimit: aiCallLimit,
            activities: activityItems.map { $0.toAIRecommendation() }
        )
    }
}
