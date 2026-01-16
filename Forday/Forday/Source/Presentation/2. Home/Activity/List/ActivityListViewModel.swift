//
//  ActivityListViewModel.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation
import Combine

class ActivityListViewModel {
    
    // Published Properties
    
    @Published var activities: [Activity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // UseCase
    private let fetchActivityListUseCase: FetchActivityListUseCase
    private let updateActivityUseCase: UpdateActivityUseCase
    private let deleteActivityUseCase: DeleteActivityUseCase
    
    // Initialization
    
    init(
        fetchActivityListUseCase: FetchActivityListUseCase = FetchActivityListUseCase(),
        updateActivityUseCase: UpdateActivityUseCase = UpdateActivityUseCase(),
        deleteActivityUseCase: DeleteActivityUseCase = DeleteActivityUseCase()
    ) {
        self.fetchActivityListUseCase = fetchActivityListUseCase
        self.updateActivityUseCase = updateActivityUseCase
        self.deleteActivityUseCase = deleteActivityUseCase
    }
    
    // Methods
    
    func fetchActivities(hobbyId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let activities = try await fetchActivityListUseCase.execute(hobbyId: hobbyId)
            
            await MainActor.run {
                self.activities = activities
                self.isLoading = false
                print("✅ 활동 목록 로드 완료: \(activities.count)개")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print("❌ 활동 목록 로드 실패: \(error)")
            }
        }
    }
    
    func updateActivity(activityId: Int, content: String) async throws {
        let message = try await updateActivityUseCase.execute(activityId: activityId, content: content)
        print("✅ 활동 수정 완료: \(message)")
    }
    
    func deleteActivity(activityId: Int) async throws {
        let message = try await deleteActivityUseCase.execute(activityId: activityId)
        print("✅ 활동 삭제 완료: \(message)")
        
        // 목록에서 제거
        await MainActor.run {
            activities.removeAll { $0.activityId == activityId }
        }
    }
}