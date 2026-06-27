//
//  CreateActivityRecordV2Response.swift
//  Forday
//
//  Created by Subeen on 6/27/26.
//

import Foundation

extension DTO {
    struct CreateActivityRecordV2Response: BaseResponse {
        let status: Int
        let success: Bool
        let data: CreateActivityRecordV2Data
    }

    struct CreateActivityRecordV2Data: Codable {
        let activityRecordId: Int
        let hobbyName: String
        let activityContent: String
        let sticker: String
        let memo: String?
        let visibility: String
        let images: [RecordImageOutput]
    }

    struct RecordImageOutput: Codable {
        let imageId: Int
        let imageUrl: String
        let imageOrder: Int
        let imageWidth: Int
        let imageHeight: Int
        let thumbnail: Bool
    }
}

extension DTO.CreateActivityRecordV2Response {
    func toDomain() -> ActivityRecordV2 {
        return ActivityRecordV2(
            activityRecordId: data.activityRecordId,
            hobbyName: data.hobbyName,
            activityContent: data.activityContent,
            sticker: data.sticker,
            memo: data.memo,
            visibility: data.visibility,
            images: data.images.map { image in
                ActivityRecordImage(
                    imageId: image.imageId,
                    imageUrl: image.imageUrl,
                    imageOrder: image.imageOrder,
                    imageWidth: image.imageWidth,
                    imageHeight: image.imageHeight,
                    isThumbnail: image.thumbnail
                )
            }
        )
    }
}
