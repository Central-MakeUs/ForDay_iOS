//
//  UsersRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import Foundation

protocol UsersRepositoryInterface {
    func checkNicknameAvailability(nickname: String) async throws -> NicknameCheckResult
    func setNickname(nickname: String) async throws -> SetNicknameResult
    func fetchUserInfo(userId: String?) async throws -> UserInfo
    func fetchHobbyCards(lastHobbyCardId: Int?, size: Int, userId: String?) async throws -> HobbyCardsResult
    func updateProfileImage(profileImageUrl: String?) async throws -> UpdateProfileImageResult
    func fetchFeeds(hobbyIds: [Int], lastRecordId: Int?, feedSize: Int, userId: String?) async throws -> FeedResult
    func fetchScraps(lastRecordId: Int?, feedSize: Int, userId: String?) async throws -> FeedResult
}
