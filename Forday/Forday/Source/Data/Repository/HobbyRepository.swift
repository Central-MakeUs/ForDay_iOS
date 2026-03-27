//
//  HobbyRepository.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

final class HobbyRepository: HobbyRepositoryInterface {

    private let activityService: ActivityService

    init(activityService: ActivityService = ActivityService()) {
        self.activityService = activityService
    }

    func createHobby(
        hobbyInfoId: Int?,
        hobbyName: String,
        hobbyTimeMinutes: Int,
        hobbyPurpose: String,
        executionCount: Int,
        isDurationSet: Bool
    ) async throws -> Int {
        let request = DTO.CreateHobbyRequest(
            hobbyInfoId: hobbyInfoId,
            hobbyName: hobbyName,
            hobbyTimeMinutes: hobbyTimeMinutes,
            hobbyPurpose: hobbyPurpose,
            executionCount: executionCount,
            isDurationSet: isDurationSet
        )

        let response = try await activityService.createHobby(request: request)
        return response.data.hobbyId
    }

    func updateHobby(
        hobbyId: Int,
        hobbyInfoId: Int?,
        hobbyName: String,
        hobbyTimeMinutes: Int,
        hobbyPurpose: String,
        executionCount: Int,
        isDurationSet: Bool
    ) async throws -> Int {
        let request = DTO.UpdateHobbyRequest(
            hobbyInfoId: hobbyInfoId,
            hobbyName: hobbyName,
            hobbyTimeMinutes: hobbyTimeMinutes,
            hobbyPurpose: hobbyPurpose,
            executionCount: executionCount,
            durationSet: isDurationSet
        )

        let response = try await activityService.updateHobby(hobbyId: hobbyId, request: request)
        return response.data.hobbyId
    }

    func fetchHomeInfo(hobbyId: Int?) async throws -> HomeInfo? {
        let response = try await activityService.fetchHomeInfo(hobbyId: hobbyId)
        return response.toDomain()
    }

    func fetchHobbyChips(status: String = "IN_PROGRESS") async throws -> [HobbyChip] {
        let response = try await activityService.fetchHobbyChips(status: status)
        return response.toDomain()
    }

    func fetchHobbySettings(hobbyStatus: HobbyStatus?) async throws -> HobbySettings {
        let response = try await activityService.fetchHobbySettings(hobbyStatus: hobbyStatus?.rawValue)
        return response.toDomain()
    }

    func updateHobbyTime(hobbyId: Int, minutes: Int) async throws -> String {
        let request = DTO.UpdateHobbyTimeRequest(minutes: minutes)
        let response = try await activityService.updateHobbyTime(hobbyId: hobbyId, request: request)
        return response.toDomain()
    }

    func updateExecutionCount(hobbyId: Int, executionCount: Int) async throws -> String {
        let request = DTO.UpdateExecutionCountRequest(executionCount: executionCount)
        let response = try await activityService.updateExecutionCount(hobbyId: hobbyId, request: request)
        return response.toDomain()
    }

    func updateGoalDays(hobbyId: Int, isDurationSet: Bool) async throws -> String {
        let request = DTO.UpdateGoalDaysRequest(isDurationSet: isDurationSet)
        let response = try await activityService.updateGoalDays(hobbyId: hobbyId, request: request)
        return response.toDomain()
    }

    func updateHobbyStatus(hobbyId: Int, hobbyStatus: HobbyStatus) async throws -> String {
        let request = DTO.UpdateHobbyStatusRequest(hobbyStatus: hobbyStatus.rawValue)
        let response = try await activityService.updateHobbyStatus(hobbyId: hobbyId, request: request)
        return response.toDomain()
    }

    func updateCoverImage(hobbyId: Int?, coverImageUrl: String?, recordId: Int?) async throws -> UpdateHobbyCoverResult {
        let request = DTO.UpdateHobbyCoverRequest(
            hobbyId: hobbyId,
            coverImageUrl: coverImageUrl,
            recordId: recordId
        )
        let response = try await activityService.updateCoverImage(request: request)
        return response.toDomain()
    }
}
