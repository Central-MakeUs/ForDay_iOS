//
//  HobbyRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

protocol HobbyRepositoryInterface {
    /// v1 API: 취미 단건 생성
    func createHobby(
        hobbyInfoId: Int?,
        hobbyName: String,
        hobbyTimeMinutes: Int,
        hobbyPurpose: String,
        executionCount: Int,
        isDurationSet: Bool
    ) async throws -> Int

    /// v2 API: 취미 여러 개 한번에 생성 (새 회원가입 플로우용)
    func createHobbyV2(hobbies: [(hobbyInfoId: Int?, hobbyName: String)]) async throws -> [Int]

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
    func fetchHobbySettingsV2() async throws -> HobbySettingsV2
    func updateHobbySettingsV2(progressHobbies: [(hobbyId: Int, sequence: Int)], hiddenHobbies: [(hobbyId: Int, sequence: Int)]) async throws -> HobbySettingsV2
    func updateHobbyTime(hobbyId: Int, minutes: Int) async throws -> String
    func updateExecutionCount(hobbyId: Int, executionCount: Int) async throws -> String
    func updateGoalDays(hobbyId: Int, isDurationSet: Bool) async throws -> String
    func updateHobbyStatus(hobbyId: Int, hobbyStatus: HobbyStatus) async throws -> String
    func updateCoverImage(hobbyId: Int?, coverImageUrl: String?, recordId: Int?) async throws -> UpdateHobbyCoverResult
}
