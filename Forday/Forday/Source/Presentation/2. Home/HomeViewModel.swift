//
//  HomeViewModel.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation
import Combine

class HomeViewModel {
    
    // Published Properties
    
    @Published var onboardingData: OnboardingData?
    @Published var activities: [Activity] = []
    @Published var aiRecommendationResult: AIRecommendationResult?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Storage
    private let onboardingStorage = OnboardingDataStorage.shared
    
    // UseCase
    private let fetchAIRecommendationsUseCase: FetchAIRecommendationsUseCase
    
    // Initialization
    
    init(fetchAIRecommendationsUseCase: FetchAIRecommendationsUseCase = FetchAIRecommendationsUseCase()) {
        self.fetchAIRecommendationsUseCase = fetchAIRecommendationsUseCase
    }
    
    // Methods
    
    func loadOnboardingData() {
        do {
            let data = try onboardingStorage.load()
            onboardingData = data
            print("✅ 온보딩 데이터 로드 성공: \(data)")
        } catch {
            print("❌ 온보딩 데이터 로드 실패: \(error)")
        }
    }
    
    func fetchAIRecommendations() async throws {
        guard let data = onboardingData,
              let hobbyCard = data.selectedHobbyCard,
              let hobbyId = hobbyCard.id else {
            throw NSError(domain: "HomeViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "온보딩 데이터 없음"])
        }
        
        print("🔍 AI 추천 요청 시작 - hobbyId: \(hobbyId)")
        
        let result = try await fetchAIRecommendationsUseCase.execute(hobbyId: hobbyId)
        
        await MainActor.run {
            self.aiRecommendationResult = result
            print("✅ AI 추천 완료: \(result.activities.count)개")
            print("호출 횟수: \(result.aiCallCount)/\(result.aiCallLimit)")
        }
    }
}

// MARK: - Models

//struct Activity {
//    let id: Int
//    let name: String
//    let isCompleted: Bool
//}
