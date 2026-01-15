//
//  ActivityRepository.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation

final class ActivityRepository: ActivityRepositoryInterface {
    
    private let activityService: ActivityService
    
    init(activityService: ActivityService = ActivityService()) {
        self.activityService = activityService
    }
    
    func fetchAIRecommendations(hobbyId: Int) async throws -> AIRecommendationResult {
        do {
            let response = try await activityService.fetchAIRecommendations(hobbyId: hobbyId)
            return response.toDomain()
        } catch {
            #if DEBUG
            print("⚠️ API 실패 - 목 데이터 사용")
            print("⚠️ 에러 내용: \(error)")
            return makeMockData()
            #else
            throw error
            #endif
        }
    }
    
    #if DEBUG
    private func makeMockData() -> AIRecommendationResult {
        return AIRecommendationResult(
            message: "AI가 취미 활동을 추천했습니다.",
            aiCallCount: 1,
            aiCallLimit: 3,
            activities: [
                AIRecommendation(
                    activityId: 1,
                    topic: "책 5 페이지 읽기",
                    content: "책 5 페이지 읽기",
                    description: "끝이 정해진 독서라, 시작이 가볍습니다."
                ),
                AIRecommendation(
                    activityId: 2,
                    topic: "문단 1개 소리내서 읽기",
                    content: "문단 1개 소리내서 읽기",
                    description: "소리 내어 읽으면 생각보다 마음이 편하고, 잘못된 문장 하나가 있어도 중요하지 않습니다."
                ),
                AIRecommendation(
                    activityId: 3,
                    topic: "줄글로 독서",
                    content: "줄글로 독서",
                    description: "아침에 하는 즐겁고 편안한 독서가 가장 좋은 시작이 될 수 있어요."
                )
            ]
        )
    }
    #endif
}
