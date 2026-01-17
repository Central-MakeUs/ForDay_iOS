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

    func fetchOthersActivities(hobbyId: Int) async throws -> OthersActivityResult {
        do {
            let response = try await activityService.fetchOthersActivities(hobbyId: hobbyId)
            return response.toDomain()
        } catch {
            #if DEBUG
            print("⚠️ 다른 포비들 활동 API 실패 - 목 데이터 사용")
            print("⚠️ 에러 내용: \(error)")
            return makeMockOthersActivities()
            #else
            throw error
            #endif
        }
    }

    func fetchAIRecommendations(hobbyId: Int) async throws -> AIRecommendationResult {
        do {
            let response = try await activityService.fetchAIRecommendations(hobbyId: hobbyId)
            return response.toDomain()
        } catch {
            #if DEBUG
            print("⚠️ API 실패 - 목 데이터 사용")
            print("⚠️ 에러 내용: \(error)")
            return makeMockAIData()
            #else
            throw error
            #endif
        }
    }
    
    func fetchActivityList(hobbyId: Int) async throws -> [Activity] {
        do {
            let response = try await activityService.fetchActivityList(hobbyId: hobbyId)
            return response.toDomain()
        } catch {
            #if DEBUG
            print("⚠️ 활동 목록 API 실패 - 목 데이터 사용")
            return makeMockActivityList()
            #else
            throw error
            #endif
        }
    }
    
    func createActivities(hobbyId: Int, activities: [ActivityInput]) async throws -> String {
        let dtoActivities = activities.map {
            DTO.ActivityInput(aiRecommended: $0.aiRecommended, content: $0.content)
        }
        let request = DTO.CreateActivitiesRequest(activities: dtoActivities)
        let response = try await activityService.createActivities(hobbyId: hobbyId, request: request)
        return response.toDomain()
    }
    
    func updateActivity(activityId: Int, content: String) async throws -> String {
        let request = DTO.UpdateActivityRequest(content: content)
        let response = try await activityService.updateActivity(activityId: activityId, request: request)
        return response.toDomain()
    }
    
    func deleteActivity(activityId: Int) async throws -> String {
        let response = try await activityService.deleteActivity(activityId: activityId)
        return response.toDomain()
    }
}


#if DEBUG
extension ActivityRepository {
    
    func makeMockAIData() -> AIRecommendationResult {
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
    
    func makeMockActivityList() -> [Activity] {
        return [
            Activity(
                activityId: 1,
                content: "미라클 모닝 아침 독서",
                aiRecommended: false,
                deletable: false,
                stickers: [
                    ActivitySticker(activityRecordId: 1, sticker: "smile.jpg"),
                    ActivitySticker(activityRecordId: 2, sticker: "smile.jpg")
                ]
            ),
            Activity(
                activityId: 2,
                content: "한 챕터마다 독후감 쓰기",
                aiRecommended: false,
                deletable: true,
                stickers: []
            ),
            Activity(
                activityId: 3,
                content: "SNS 독서 인증",
                aiRecommended: true,
                deletable: true,
                stickers: []
            )
        ]
    }

    func makeMockOthersActivities() -> OthersActivityResult {
        return OthersActivityResult(
            message: "다른 포비들의 인기 활동을 조회했습니다.",
            activities: [
                OthersActivity(id: 1, content: "SNS에 인증하기"),
                OthersActivity(id: 2, content: "인증사진 남기기"),
                OthersActivity(id: 3, content: "기록 남기기")
            ]
        )
    }
}
#endif
