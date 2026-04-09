//
//  MyPageRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

protocol MyPageRepositoryInterface {
    func fetchUserInfo(userId: String?) async throws -> UserInfo
    func fetchMyHobbies(userId: String?) async throws -> MyHobbiesResult
    func fetchActivityDetail(activityRecordId: Int) async throws -> ActivityDetail
    func fetchActivityDetailV2(activityRecordId: Int, context: ActivityDetailContext) async throws -> ActivityDetail
    func updateProfile(nickname: String, profileImageUrl: String) async throws -> UserInfo
    func addReaction(recordId: Int, reactionType: ReactionType) async throws -> AddReactionResult
    func deleteReaction(recordId: Int, reactionType: ReactionType) async throws -> DeleteReactionResult
    func fetchReactionUsers(recordId: Int, reactionType: ReactionType, lastUserId: String?, size: Int) async throws -> FetchReactionUsersResult
    func fetchReactionSummary(recordId: Int, size: Int) async throws -> ReactionSummaryResponse
    func fetchReactionTabData(recordId: Int, reactionType: ReactionType?, lastReactionId: Int, size: Int) async throws -> ReactionTabData
    func addScrap(recordId: Int) async throws -> ScrapResult
    func deleteScrap(recordId: Int) async throws -> ScrapResult
}
