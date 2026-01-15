//
//  AIRecommendation.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation

struct AIRecommendationResult {
    let message: String
    let aiCallCount: Int
    let aiCallLimit: Int
    let activities: [AIRecommendation]
}

struct AIRecommendation {
    let activityId: Int
    let topic: String
    let content: String
    let description: String
}

extension AIRecommendationResult {
    static var stub01: AIRecommendationResult = .init(message: "test01", aiCallCount: 1, aiCallLimit: 3, activities: [.stub01, .stub02, .stub03])
}

extension AIRecommendation {
    static var stub01: AIRecommendation = .init(activityId: 1, topic: "그림 그리기", content: "test content", description: "test description")
    static var stub02: AIRecommendation = .init(activityId: 2, topic: "그림 그리기", content: "test content", description: "test description")
    static var stub03: AIRecommendation = .init(activityId: 3, topic: "그림 그리기", content: "test content", description: "test description")
}
