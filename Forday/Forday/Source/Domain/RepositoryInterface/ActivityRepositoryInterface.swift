//
//  ActivityRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation

protocol ActivityRepositoryInterface {
    func fetchOthersActivities(hobbyId: Int) async throws -> OthersActivityResult
    func fetchAIRecommendations(hobbyId: Int) async throws -> AIRecommendationResult
    func fetchActivityList(hobbyId: Int) async throws -> [Activity]
    func createActivities(hobbyId: Int, activities: [ActivityInput]) async throws -> String
    func updateActivity(activityId: Int, content: String) async throws -> String
    func deleteActivity(activityId: Int) async throws -> String
}

