//
//  ActivityRecordDetailResponse.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

extension DTO {
    struct ActivityRecordDetailResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: ActivityRecordDetailData
    }

    struct ActivityRecordDetailData: Codable {
        let hobbyId: Int
        let activityId: Int?
        let activityContent: String
        let activityRecordId: Int
        let imageUrl: String?
        let sticker: String
        let createdAt: String
        let memo: String?
        let recordOwner: Bool
        let scraped: Bool?
        let userInfo: UserInfo?        
        let visibility: String
        let newReaction: NewReaction
        let userReaction: UserReaction
    }

    struct UserInfo: Codable {
        let userId: String?
        let nickname: String?
        let profileImageUrl: String?
    }

    struct NewReaction: Codable {
        let newAweSome: Bool
        let newGreat: Bool
        let newAmazing: Bool
        let newFighting: Bool
    }

    struct UserReaction: Codable {
        let pressedAweSome: Bool
        let pressedGreat: Bool
        let pressedAmazing: Bool
        let pressedFighting: Bool
    }
}

// MARK: - Domain Mapping

extension DTO.ActivityRecordDetailResponse {
    func toDomain() -> ActivityDetail {
        return ActivityDetail(
            activityRecordId: data.activityRecordId,
            hobbyId: data.hobbyId,
            activityId: data.activityId ?? 0,
            activityContent: data.activityContent,
            imageUrl: data.imageUrl ?? "",  // Handle optional imageUrl with empty string fallback
            sticker: data.sticker,
            createdAt: data.createdAt,
            memo: data.memo ?? "",
            recordOwner: data.recordOwner,
            scraped: data.scraped ?? false,
            userInfo: data.userInfo?.toDomain(),
            visibility: data.visibility,
            newReaction: data.newReaction.toDomain(),
            userReaction: data.userReaction.toDomain()
        )
    }
}

extension DTO.UserInfo {
    func toDomain() -> ActivityDetailUserInfo? {
        guard let userId = userId, let nickname = nickname else {
            return nil
        }
        return ActivityDetailUserInfo(
            userId: userId,
            nickname: nickname,
            profileImageUrl: profileImageUrl
        )
    }
}

extension DTO.NewReaction {
    func toDomain() -> ReactionStatus {
        return ReactionStatus(
            awesome: newAweSome,
            great: newGreat,
            amazing: newAmazing,
            fighting: newFighting
        )
    }
}

extension DTO.UserReaction {
    func toDomain() -> ReactionStatus {
        return ReactionStatus(
            awesome: pressedAweSome,
            great: pressedGreat,
            amazing: pressedAmazing,
            fighting: pressedFighting
        )
    }
}
