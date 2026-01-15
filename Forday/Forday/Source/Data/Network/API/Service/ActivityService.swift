//
//  ActivityService.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation
import Moya

final class ActivityService {
    
    private let provider: MoyaProvider<HobbiesTarget>
    
    init(provider: MoyaProvider<HobbiesTarget> = MoyaProvider<HobbiesTarget>(plugins: [MoyaLoggingPlugin()])) {
        self.provider = provider
    }
    
    // MARK: - Fetch AI Recommendations
    
    func fetchAIRecommendations(hobbyId: Int) async throws -> DTO.AIRecommendationResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.fetchAIRecommendations(hobbyId: hobbyId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.AIRecommendationResponse.self, from: response.data)
                        continuation.resume(returning: decodedResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
