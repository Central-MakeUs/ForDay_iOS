//
//  ActivityRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation

protocol ActivityRepositoryInterface {
    func fetchAIRecommendations(hobbyId: Int) async throws -> AIRecommendationResult
}

