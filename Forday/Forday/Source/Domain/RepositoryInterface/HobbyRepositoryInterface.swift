//
//  HobbyRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

protocol HobbyRepositoryInterface {
    func createHobby(
        hobbyInfoId: Int?,
        hobbyName: String,
        hobbyTimeMinutes: Int,
        hobbyPurpose: String,
        executionCount: Int,
        isDurationSet: Bool
    ) async throws -> Int

    /// 온보딩 중 취미 수정 (nicknameSet: false && onboardingCompleted: true 상태)
    func updateHobby(
        hobbyId: Int,
        hobbyInfoId: Int?,
        hobbyName: String,
        hobbyTimeMinutes: Int,
        hobbyPurpose: String,
        executionCount: Int,
        isDurationSet: Bool
    ) async throws -> Int

    func fetchHomeInfo(hobbyId: Int?) async throws -> HomeInfo?
    func fetchHobbyChips(status: String) async throws -> [HobbyChip]

    // Hobby Management
    func fetchHobbySettings(hobbyStatus: HobbyStatus?) async throws -> HobbySettings
    func updateHobbyTime(hobbyId: Int, minutes: Int) async throws -> String
    func updateExecutionCount(hobbyId: Int, executionCount: Int) async throws -> String
    func updateGoalDays(hobbyId: Int, isDurationSet: Bool) async throws -> String
    func updateHobbyStatus(hobbyId: Int, hobbyStatus: HobbyStatus) async throws -> String
    func updateCoverImage(hobbyId: Int?, coverImageUrl: String?, recordId: Int?) async throws -> UpdateHobbyCoverResult
}
