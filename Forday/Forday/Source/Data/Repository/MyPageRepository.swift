//
//  MyPageRepository.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class MyPageRepository: MyPageRepositoryInterface {

    private let usersService: UsersService
    private let recordsService: RecordsService

    init(usersService: UsersService = UsersService(), recordsService: RecordsService = RecordsService()) {
        self.usersService = usersService
        self.recordsService = recordsService
    }

    func fetchUserInfo() async throws -> UserInfo {
        let response = try await usersService.fetchUserInfo()

        return response.toDomain()
    }

    func fetchMyHobbies() async throws -> MyHobbiesResult {
        let response = try await usersService.fetchHobbiesInProgress()
        return response.toDomain()
    }

    func fetchActivityDetail(activityRecordId: Int) async throws -> ActivityDetail {
        let response = try await recordsService.fetchRecordDetail(recordId: activityRecordId)
        return response.toDomain()
    }

    func updateProfile(nickname: String, profileImageUrl: String) async throws -> UserInfo {
        // TODO: Implement API call when ready
        throw AppError.unknown(NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: "프로필 업데이트 API가 아직 준비되지 않았습니다."]))
    }

    func addReaction(recordId: Int, reactionType: ReactionType) async throws -> AddReactionResult {
        let response = try await recordsService.addReaction(recordId: recordId, reactionType: reactionType)
        return response.toDomain()
    }

    func deleteReaction(recordId: Int, reactionType: ReactionType) async throws -> DeleteReactionResult {
        let response = try await recordsService.deleteReaction(recordId: recordId, reactionType: reactionType)
        return response.toDomain()
    }

    func fetchReactionUsers(recordId: Int, reactionType: ReactionType, lastUserId: String?, size: Int) async throws -> FetchReactionUsersResult {
        let response = try await recordsService.fetchReactionUsers(
            recordId: recordId,
            reactionType: reactionType,
            lastUserId: lastUserId,
            size: size
        )
        return response.toDomain()
    }

    func addScrap(recordId: Int) async throws -> ScrapResult {
        let response = try await recordsService.addScrap(recordId: recordId)
        return response.toDomain()
    }

    func deleteScrap(recordId: Int) async throws -> ScrapResult {
        let response = try await recordsService.deleteScrap(recordId: recordId)
        return response.toDomain()
    }
}

