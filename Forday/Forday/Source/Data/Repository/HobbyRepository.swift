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
        hobbyCardId: Int,
        hobbyName: String,
        hobbyTimeMinutes: Int,
        hobbyPurpose: String,
        executionCount: Int,
        isDurationSet: Bool
    ) async throws -> Int {
        let request = DTO.CreateHobbyRequest(
            hobbyCardId: hobbyCardId,
            hobbyName: hobbyName,
            hobbyTimeMinutes: hobbyTimeMinutes,
            hobbyPurpose: hobbyPurpose,
            executionCount: executionCount,
            isDurationSet: isDurationSet
        )

        let response = try await activityService.createHobby(request: request)
        return response.data.hobbyId
    }
}
