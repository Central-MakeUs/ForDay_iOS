//
//  HobbyActivityInputViewModel.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation
import Combine

class HobbyActivityInputViewModel {
    
    // Published Properties
    
    @Published var activities: [(content: String, aiRecommended: Bool)] = []
    @Published var isSaveButtonEnabled: Bool = false
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // UseCase
    private let createActivitiesUseCase: CreateActivitiesUseCase
    
    // Initialization
    
    init(createActivitiesUseCase: CreateActivitiesUseCase = CreateActivitiesUseCase()) {
        self.createActivitiesUseCase = createActivitiesUseCase
    }
    
    // Methods
    
    func updateActivities(_ activities: [(content: String, aiRecommended: Bool)]) {
        self.activities = activities
        
        // 최소 1개 이상의 활동이 있고, 모든 활동의 내용이 비어있지 않으면 저장 가능
        isSaveButtonEnabled = !activities.isEmpty && activities.allSatisfy { !$0.content.isEmpty }
    }
    
    func createActivities(hobbyId: Int, activities: [(content: String, aiRecommended: Bool)]) async throws {
        isLoading = true
        
        let activityInputs = activities.map {
            ActivityInput(aiRecommended: $0.aiRecommended, content: $0.content)
        }
        
        do {
            let message = try await createActivitiesUseCase.execute(hobbyId: hobbyId, activities: activityInputs)
            
            await MainActor.run {
                self.isLoading = false
                print("✅ 활동 생성 완료: \(message)")
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            throw error
        }
    }
}