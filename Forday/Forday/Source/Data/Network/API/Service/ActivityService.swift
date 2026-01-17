//
//  ActivityService.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation
import Moya

import Foundation
import Moya

final class ActivityService {

    private let provider: MoyaProvider<HobbiesTarget>

    init(provider: MoyaProvider<HobbiesTarget> = NetworkProvider.createProvider()) {
        self.provider = provider
    }

    // MARK: - 취미 생성

    func createHobby(request: DTO.CreateHobbyRequest) async throws -> DTO.CreateHobbyResponse {
        return try await provider.request(.createHobby(request: request))
    }

    // MARK: - 홈 정보 조회

    func fetchHomeInfo(hobbyId: Int?) async throws -> DTO.HomeInfoResponse {
        return try await provider.request(.fetchHomeInfo(hobbyId: hobbyId))
    }

    // MARK: - 다른 포비들의 활동 조회

    func fetchOthersActivities(hobbyId: Int) async throws -> DTO.OthersActivitiesResponse {
        return try await provider.request(.fetchOthersActivities(hobbyId: hobbyId))
    }

    // MARK: - AI 추천

    func fetchAIRecommendations(hobbyId: Int) async throws -> DTO.AIRecommendationResponse {
        return try await provider.request(.fetchAIRecommendations(hobbyId: hobbyId))
    }
    
    // MARK: - 활동 목록 조회

    func fetchActivityList(hobbyId: Int) async throws -> DTO.ActivityListResponse {
        return try await provider.request(.fetchActivityList(hobbyId: hobbyId))
    }
    
    // MARK: - 활동 생성

    func createActivities(hobbyId: Int, request: DTO.CreateActivitiesRequest) async throws -> DTO.CreateActivitiesResponse {
        return try await provider.request(.createActivities(hobbyId: hobbyId, request: request))
    }
    
    // MARK: - 활동 수정

    func updateActivity(activityId: Int, request: DTO.UpdateActivityRequest) async throws -> DTO.UpdateActivityResponse {
        return try await provider.request(.updateActivity(activityId: activityId, request: request))
    }
    
    // MARK: - 활동 삭제

    func deleteActivity(activityId: Int) async throws -> DTO.DeleteActivityResponse {
        return try await provider.request(.deleteActivity(activityId: activityId))
    }
}
