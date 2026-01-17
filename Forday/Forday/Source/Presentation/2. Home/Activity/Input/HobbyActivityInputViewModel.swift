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
    @Published var othersActivities: [OthersActivity] = []
    @Published var isSaveButtonEnabled: Bool = false
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()

    // UseCase
    private let fetchOthersActivitiesUseCase: FetchOthersActivitiesUseCase
    private let createActivitiesUseCase: CreateActivitiesUseCase

    // Initialization

    init(
        fetchOthersActivitiesUseCase: FetchOthersActivitiesUseCase = FetchOthersActivitiesUseCase(),
        createActivitiesUseCase: CreateActivitiesUseCase = CreateActivitiesUseCase()
    ) {
        self.fetchOthersActivitiesUseCase = fetchOthersActivitiesUseCase
        self.createActivitiesUseCase = createActivitiesUseCase
    }
    
    // Methods

    func fetchOthersActivities(hobbyId: Int) async {
        do {
            let result = try await fetchOthersActivitiesUseCase.execute(hobbyId: hobbyId)
            await MainActor.run {
                self.othersActivities = result.activities
                print("✅ 추천 활동 조회 완료: \(result.activities.count)개")
            }
        } catch {
            await MainActor.run {
                print("❌ 추천 활동 조회 실패: \(error)")
            }
        }
    }

    func updateActivities(_ activities: [(content: String, aiRecommended: Bool)]) {
        self.activities = activities

        // 첫 번째 활동에 텍스트가 있으면 저장 가능
        isSaveButtonEnabled = !activities.isEmpty && !activities[0].content.isEmpty
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