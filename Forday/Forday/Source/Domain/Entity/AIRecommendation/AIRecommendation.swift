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
