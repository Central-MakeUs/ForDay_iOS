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
        let hobbyName: String
        let activityId: Int?
        let activityContent: String
        let activityRecordId: Int
        let imageUrl: String?
        let imageWidth: Int?
        let imageHeight: Int?
        let sticker: String
        let createdAt: String
        let memo: String?
        let recordOwner: Bool
        let scraped: Bool?
        let userInfo: UserInfo?
        let visibility: String
        let newReaction: NewReaction
        let userReaction: UserReaction
        let prevRecordId: Int?  // 이전 기록 ID (페이징용)
        let nextRecordId: Int?  // 다음 기록 ID (페이징용)

        // TODO: 서버가 imageWidth/imageHeight를 Int? 필드로 확정해 내려주면
        // 커스텀 init(from:), encode(to:), decodeDimension을 제거하고 Codable 자동 합성으로 되돌리기.
        enum CodingKeys: String, CodingKey {
            case hobbyId
            case hobbyName
            case activityId
            case activityContent
            case activityRecordId
            case imageUrl
            case imageWidth
            case imageHeight
            case width
            case height
            case originalWidth
            case originalHeight
            case sticker
            case createdAt
            case memo
            case recordOwner
            case scraped
            case userInfo
            case visibility
            case newReaction
            case userReaction
            case prevRecordId
            case nextRecordId
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            hobbyId = try container.decode(Int.self, forKey: .hobbyId)
            hobbyName = try container.decode(String.self, forKey: .hobbyName)
            activityId = try container.decodeIfPresent(Int.self, forKey: .activityId)
            activityContent = try container.decode(String.self, forKey: .activityContent)
            activityRecordId = try container.decode(Int.self, forKey: .activityRecordId)
            imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            imageWidth = Self.decodeDimension(from: container, keys: [.imageWidth, .width, .originalWidth])
            imageHeight = Self.decodeDimension(from: container, keys: [.imageHeight, .height, .originalHeight])
            sticker = try container.decode(String.self, forKey: .sticker)
            createdAt = try container.decode(String.self, forKey: .createdAt)
            memo = try container.decodeIfPresent(String.self, forKey: .memo)
            recordOwner = try container.decode(Bool.self, forKey: .recordOwner)
            scraped = try container.decodeIfPresent(Bool.self, forKey: .scraped)
            userInfo = try container.decodeIfPresent(UserInfo.self, forKey: .userInfo)
            visibility = try container.decode(String.self, forKey: .visibility)
            newReaction = try container.decode(NewReaction.self, forKey: .newReaction)
            userReaction = try container.decode(UserReaction.self, forKey: .userReaction)
            prevRecordId = try container.decodeIfPresent(Int.self, forKey: .prevRecordId)
            nextRecordId = try container.decodeIfPresent(Int.self, forKey: .nextRecordId)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(hobbyId, forKey: .hobbyId)
            try container.encode(hobbyName, forKey: .hobbyName)
            try container.encodeIfPresent(activityId, forKey: .activityId)
            try container.encode(activityContent, forKey: .activityContent)
            try container.encode(activityRecordId, forKey: .activityRecordId)
            try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
            try container.encodeIfPresent(imageWidth, forKey: .imageWidth)
            try container.encodeIfPresent(imageHeight, forKey: .imageHeight)
            try container.encode(sticker, forKey: .sticker)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encodeIfPresent(memo, forKey: .memo)
            try container.encode(recordOwner, forKey: .recordOwner)
            try container.encodeIfPresent(scraped, forKey: .scraped)
            try container.encodeIfPresent(userInfo, forKey: .userInfo)
            try container.encode(visibility, forKey: .visibility)
            try container.encode(newReaction, forKey: .newReaction)
            try container.encode(userReaction, forKey: .userReaction)
            try container.encodeIfPresent(prevRecordId, forKey: .prevRecordId)
            try container.encodeIfPresent(nextRecordId, forKey: .nextRecordId)
        }

        private static func decodeDimension(
            from container: KeyedDecodingContainer<CodingKeys>,
            keys: [CodingKeys]
        ) -> Int? {
            for key in keys {
                if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
                    return value
                }
                if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
                    return Int(value)
                }
                if let value = try? container.decodeIfPresent(String.self, forKey: key),
                   let doubleValue = Double(value) {
                    return Int(doubleValue)
                }
            }
            return nil
        }
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
        // V1/V2 API: 단일 imageUrl을 images 배열로 변환
        var images: [ActivityDetailImage] = []
        if let imageUrl = data.imageUrl, !imageUrl.isEmpty {
            images.append(ActivityDetailImage(
                imageId: 0,  // V1/V2에서는 imageId가 없음
                imageUrl: imageUrl,
                imageOrder: 1,
                imageWidth: data.imageWidth ?? 0,
                imageHeight: data.imageHeight ?? 0,
                isThumbnail: true
            ))
        }

        return ActivityDetail(
            activityRecordId: data.activityRecordId,
            hobbyId: data.hobbyId,
            hobbyName: data.hobbyName,
            activityId: data.activityId ?? 0,
            activityContent: data.activityContent,
            images: images,
            sticker: data.sticker,
            createdAt: data.createdAt,
            memo: data.memo ?? "",
            recordOwner: data.recordOwner,
            scraped: data.scraped ?? false,
            userInfo: data.userInfo?.toDomain(),
            visibility: data.visibility,
            newReaction: data.newReaction.toDomain(),
            userReaction: data.userReaction.toDomain(),
            prevRecordId: data.prevRecordId,
            nextRecordId: data.nextRecordId
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
