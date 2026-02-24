//
//  MockHobbyRepository.swift
//  FordayTests
//
//  Created by Subeen on 2/10/26.
//

import Foundation
@testable import Forday

final class MockHobbyRepository: HobbyRepositoryInterface {

    // MARK: - Stub Data

    var homeInfoToReturn: HomeInfo?
    var hobbySettingsToReturn: HobbySettings?
    var createHobbyIdToReturn: Int = 1
    var updateResultToReturn: String = "success"
    var updateCoverResultToReturn: UpdateHobbyCoverResult = UpdateHobbyCoverResult(message: "success")
    var errorToThrow: Error?

    // MARK: - Call Tracking

    var fetchHomeInfoCallCount = 0
    var lastFetchHomeInfoHobbyId: Int?

    var createHobbyCallCount = 0
    var lastCreateHobbyParams: (hobbyInfoId: Int?, hobbyName: String, hobbyTimeMinutes: Int, hobbyPurpose: String, executionCount: Int, isDurationSet: Bool)?

    var updateHobbyCallCount = 0
    var lastUpdateHobbyParams: (hobbyId: Int, hobbyInfoId: Int?, hobbyName: String, hobbyTimeMinutes: Int, hobbyPurpose: String, executionCount: Int, isDurationSet: Bool)?
    var updateHobbyIdToReturn: Int = 1

    var fetchHobbySettingsCallCount = 0
    var lastFetchHobbySettingsStatus: HobbyStatus?

    var updateHobbyTimeCallCount = 0
    var updateExecutionCountCallCount = 0
    var updateGoalDaysCallCount = 0
    var updateHobbyStatusCallCount = 0
    var updateCoverImageCallCount = 0

    // MARK: - Reset

    func reset() {
        homeInfoToReturn = nil
        hobbySettingsToReturn = nil
        errorToThrow = nil

        fetchHomeInfoCallCount = 0
        lastFetchHomeInfoHobbyId = nil
        createHobbyCallCount = 0
        lastCreateHobbyParams = nil
        updateHobbyCallCount = 0
        lastUpdateHobbyParams = nil
        fetchHobbySettingsCallCount = 0
        lastFetchHobbySettingsStatus = nil
        updateHobbyTimeCallCount = 0
        updateExecutionCountCallCount = 0
        updateGoalDaysCallCount = 0
        updateHobbyStatusCallCount = 0
        updateCoverImageCallCount = 0
    }

    // MARK: - HobbyRepositoryInterface

    func fetchHomeInfo(hobbyId: Int?) async throws -> HomeInfo? {
        fetchHomeInfoCallCount += 1
        lastFetchHomeInfoHobbyId = hobbyId

        if let error = errorToThrow {
            throw error
        }
        return homeInfoToReturn
    }

    func createHobby(
        hobbyInfoId: Int?,
        hobbyName: String,
        hobbyTimeMinutes: Int,
        hobbyPurpose: String,
        executionCount: Int,
        isDurationSet: Bool
    ) async throws -> Int {
        createHobbyCallCount += 1
        lastCreateHobbyParams = (hobbyInfoId, hobbyName, hobbyTimeMinutes, hobbyPurpose, executionCount, isDurationSet)

        if let error = errorToThrow {
            throw error
        }
        return createHobbyIdToReturn
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
        updateHobbyCallCount += 1
        lastUpdateHobbyParams = (hobbyId, hobbyInfoId, hobbyName, hobbyTimeMinutes, hobbyPurpose, executionCount, isDurationSet)

        if let error = errorToThrow {
            throw error
        }
        return updateHobbyIdToReturn
    }

    func fetchHobbySettings(hobbyStatus: HobbyStatus?) async throws -> HobbySettings {
        fetchHobbySettingsCallCount += 1
        lastFetchHobbySettingsStatus = hobbyStatus

        if let error = errorToThrow {
            throw error
        }
        guard let settings = hobbySettingsToReturn else {
            fatalError("hobbySettingsToReturn not set")
        }
        return settings
    }

    func updateHobbyTime(hobbyId: Int, minutes: Int) async throws -> String {
        updateHobbyTimeCallCount += 1

        if let error = errorToThrow {
            throw error
        }
        return updateResultToReturn
    }

    func updateExecutionCount(hobbyId: Int, executionCount: Int) async throws -> String {
        updateExecutionCountCallCount += 1

        if let error = errorToThrow {
            throw error
        }
        return updateResultToReturn
    }

    func updateGoalDays(hobbyId: Int, isDurationSet: Bool) async throws -> String {
        updateGoalDaysCallCount += 1

        if let error = errorToThrow {
            throw error
        }
        return updateResultToReturn
    }

    func updateHobbyStatus(hobbyId: Int, hobbyStatus: HobbyStatus) async throws -> String {
        updateHobbyStatusCallCount += 1

        if let error = errorToThrow {
            throw error
        }
        return updateResultToReturn
    }

    func updateCoverImage(hobbyId: Int?, coverImageUrl: String?, recordId: Int?) async throws -> UpdateHobbyCoverResult {
        updateCoverImageCallCount += 1

        if let error = errorToThrow {
            throw error
        }
        return updateCoverResultToReturn
    }
}
