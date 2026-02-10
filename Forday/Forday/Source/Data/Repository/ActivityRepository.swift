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
        let response = try await activityService.fetchOthersActivities(hobbyId: hobbyId)
        return response.toDomain()
    }

    func fetchAIRecommendations(hobbyId: Int) async throws -> AIRecommendationResult {
        let response = try await activityService.fetchAIRecommendations(hobbyId: hobbyId)
        return response.toDomain()
    }
    
    func fetchActivityList(hobbyId: Int) async throws -> [Activity] {
        let response = try await activityService.fetchActivityList(hobbyId: hobbyId)
        return response.toDomain()
    }

    func fetchActivityDropdownList(hobbyId: Int, size: Int? = nil) async throws -> [Activity] {
        let response = try await activityService.fetchActivityDropdownList(hobbyId: hobbyId, size: size)
        return response.toDomain()
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

    func createActivityRecord(activityId: Int, sticker: String, memo: String?, imageUrl: String?, visibility: Privacy) async throws -> ActivityRecord {
        let request = DTO.CreateActivityRecordRequest(
            sticker: sticker,
            memo: memo,
            imageUrl: imageUrl,
            visibility: visibility.rawValue
        )
        let response = try await activityService.createActivityRecord(activityId: activityId, request: request)
        return response.toDomain()
    }

    // MARK: - Result Enum Pattern: Repository interprets business states

    func fetchStickerBoard(hobbyId: Int?, page: Int?, size: Int?) async throws -> StickerBoardResult {
        do {
            let response = try await activityService.fetchStickerBoard(hobbyId: hobbyId, page: page, size: size)

            // DTO가 자동으로 domain mapping 처리
            return response.toDomain()

        } catch let appError as AppError {
            // INVALID_HOBBY_STATUS (400): 취미가 보관처리됨 → noHobbyInProgress 반환
            if case .server(let serverError) = appError,
               serverError.errorClassName == "INVALID_HOBBY_STATUS" {
                print("ℹ️ 스티커판 - 진행 중인 취미 없음 (INVALID_HOBBY_STATUS)")
                return .noHobbyInProgress
            }

            // 그 외 서버 에러는 throw
            throw appError

        } catch {
            // 네트워크 에러 등은 throw
            throw error
        }
    }
}
