//
//  ActivityRecordDetailV3Response.swift
//  Forday
//
//  Created by Subeen on 6/27/26.
//

import Foundation

extension DTO {
    struct ActivityRecordDetailV3Response: BaseResponse {
        let status: Int
        let success: Bool
        let data: ActivityRecordDetailV3Data
    }

    struct ActivityRecordDetailV3Data: Codable {
        let hobbyId: Int
        let hobbyName: String
        let activityId: Int?
        let activityContent: String
        let activityRecordId: Int
        let images: [RecordImageOutput]
        let sticker: String
        let createdAt: String
        let memo: String?
        let recordOwner: Bool
        let scraped: Bool?
        let userInfo: UserInfo?
        let visibility: String
        let newReaction: NewReaction
        let userReaction: UserReaction
        let prevRecordId: Int?
        let nextRecordId: Int?
    }

}

// MARK: - Domain Mapping

extension DTO.ActivityRecordDetailV3Response {
    func toDomain() -> ActivityDetail {
        // 대표 이미지 (첫 번째 이미지 또는 thumbnail=true인 이미지)
        let thumbnailImage = data.images.first { $0.thumbnail } ?? data.images.first

        return ActivityDetail(
            activityRecordId: data.activityRecordId,
            hobbyId: data.hobbyId,
            hobbyName: data.hobbyName,
            activityId: data.activityId ?? 0,
            activityContent: data.activityContent,
            images: data.images.map { $0.toDomain() },
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

extension DTO.RecordImageOutput {
    func toDomain() -> ActivityDetailImage {
        return ActivityDetailImage(
            imageId: imageId,
            imageUrl: imageUrl,
            imageOrder: imageOrder,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            isThumbnail: thumbnail
        )
    }
}
