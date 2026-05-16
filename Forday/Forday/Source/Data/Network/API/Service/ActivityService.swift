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

    init(provider: MoyaProvider<HobbiesTarget> = NetworkProvider.createProvider()) {
        self.provider = provider
    }

    // MARK: - 취미 생성 (v1)

    func createHobby(request: DTO.CreateHobbyRequest) async throws -> DTO.CreateHobbyResponse {
        return try await provider.request(.createHobby(request: request))
    }

    // MARK: - 취미 생성 (v2 - 여러 개 한번에)

    func createHobbyV2(request: DTO.CreateHobbyV2Request) async throws -> DTO.CreateHobbyV2Response {
        return try await provider.request(.createHobbyV2(request: request))
    }

    // MARK: - 취미 정보 재조회 (취미 추가 시)

    func fetchHobbyInfoRecheck() async throws -> DTO.HobbyInfoRecheckResponse {
        return try await provider.request(.fetchHobbyInfoRecheck)
    }

    // MARK: - 홈 정보 조회

    func fetchHomeInfo(hobbyId: Int?) async throws -> DTO.HomeInfoResponse {
        return try await provider.request(.fetchHomeInfo(hobbyId: hobbyId))
    }
    
    // MARK: - 홈 스티커판 조회

    func fetchStickerBoard(hobbyId: Int?, page: Int?, size: Int?) async throws -> DTO.StickerBoardResponse {
        return try await provider.request(.fetchStickerBoard(hobbyId: hobbyId, page: page, size: size))
    }

    // MARK: - 다른 포비들의 활동 조회

    func fetchOthersActivities(hobbyId: Int) async throws -> DTO.OthersActivitiesResponse {
        return try await provider.request(.fetchOthersActivities(hobbyId: hobbyId))
    }

    // MARK: - AI 추천

    func fetchAIRecommendations(hobbyId: Int) async throws -> DTO.AIRecommendationResponse {
        return try await provider.request(.fetchAIRecommendations(hobbyId: hobbyId))
    }

    // MARK: - AI 추천 활동 리스트 조회

    func fetchAIActivityItems(hobbyId: Int, type: String = "ALL") async throws -> DTO.AIActivityItemsResponse {
        return try await provider.request(.fetchAIActivityItems(hobbyId: hobbyId, type: type))
    }

    // MARK: - 활동 기록 - 취미 칩 목록 조회

    func fetchHobbyChips(status: String = "IN_PROGRESS") async throws -> DTO.HobbyChipsResponse {
        return try await provider.request(.fetchHobbyChips(status: status))
    }

    // MARK: - 활동 목록 조회

    func fetchActivityList(hobbyId: Int) async throws -> DTO.ActivityListResponse {
        return try await provider.request(.fetchActivityList(hobbyId: hobbyId))
    }
    
    // MARK: - (드롭다운용) 특정 취미의 활동 목록 조회

    func fetchActivityDropdownList(hobbyId: Int, size: Int? = nil) async throws -> DTO.ActivityDropdownListResponse {
        return try await provider.request(.fetchActivityDropdownList(hobbyId: hobbyId, size: size))
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

    // MARK: - 활동 기록 작성

    func createActivityRecord(activityId: Int, request: DTO.CreateActivityRecordRequest) async throws -> DTO.CreateActivityRecordResponse {
        return try await provider.request(.createActivityRecord(activityId: activityId, request: request))
    }

    // MARK: - 취미 관리

    func fetchHobbySettings(hobbyStatus: String?) async throws -> DTO.HobbySettingsResponse {
        return try await provider.request(.fetchHobbySettings(hobbyStatus: hobbyStatus))
    }

    func fetchHobbySettingsV2() async throws -> DTO.HobbySettingsV2Response {
        return try await provider.request(.fetchHobbySettingsV2)
    }

    func updateHobbySettingsV2(request: DTO.UpdateHobbySettingsV2Request) async throws -> DTO.HobbySettingsV2Response {
        return try await provider.request(.updateHobbySettingsV2(request: request))
    }

    /// 온보딩 중 취미 수정 (nicknameSet: false && onboardingCompleted: true 상태)
    func updateHobby(hobbyId: Int, request: DTO.UpdateHobbyRequest) async throws -> DTO.UpdateHobbyDetailResponse {
        return try await provider.request(.updateHobby(hobbyId: hobbyId, request: request))
    }

    func updateHobbyTime(hobbyId: Int, request: DTO.UpdateHobbyTimeRequest) async throws -> DTO.UpdateHobbyResponse {
        return try await provider.request(.updateHobbyTime(hobbyId: hobbyId, request: request))
    }

    func updateExecutionCount(hobbyId: Int, request: DTO.UpdateExecutionCountRequest) async throws -> DTO.UpdateHobbyResponse {
        return try await provider.request(.updateExecutionCount(hobbyId: hobbyId, request: request))
    }

    func updateGoalDays(hobbyId: Int, request: DTO.UpdateGoalDaysRequest) async throws -> DTO.UpdateHobbyResponse {
        return try await provider.request(.updateGoalDays(hobbyId: hobbyId, request: request))
    }

    func updateHobbyStatus(hobbyId: Int, request: DTO.UpdateHobbyStatusRequest) async throws -> DTO.UpdateHobbyResponse {
        return try await provider.request(.updateHobbyStatus(hobbyId: hobbyId, request: request))
    }

    // MARK: - 취미 삭제

    func deleteHobby(hobbyId: Int) async throws -> DTO.DeleteHobbyResponse {
        return try await provider.request(.deleteHobby(hobbyId: hobbyId))
    }

    // MARK: - 취미 대표사진 변경

    func updateCoverImage(request: DTO.UpdateHobbyCoverRequest) async throws -> DTO.UpdateHobbyCoverResponse {
        return try await provider.request(.updateCoverImage(request: request))
    }
}
