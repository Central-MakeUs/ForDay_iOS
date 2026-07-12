//
//  UpdateRecordResponse.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

extension DTO {
    /// 활동 기록 수정 V1 Response (단일 이미지)
    struct UpdateRecordResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UpdateRecordData
    }

    struct UpdateRecordData: Codable {
        let message: String
        let activityId: Int
        let activityContent: String
        let sticker: String
        let memo: String?
        let imageUrl: String?
        let visibility: String
    }

    /// 활동 기록 수정 V2 Response (다중 이미지)
    struct UpdateRecordV2Response: BaseResponse {
        let status: Int
        let success: Bool
        let data: UpdateRecordV2Data
    }

    struct UpdateRecordV2Data: Codable {
        let message: String
        let activityRecordId: Int
        let activityId: Int
        let activityContent: String
        let sticker: String
        let memo: String?
        let visibility: String
        let images: [RecordImageOutput]
    }
}

extension DTO.UpdateRecordResponse {
    func toDomain() -> UpdateRecordResult {
        return UpdateRecordResult(
            message: data.message,
            activityRecordId: nil,
            activityId: data.activityId,
            activityContent: data.activityContent,
            sticker: data.sticker,
            memo: data.memo,
            visibility: data.visibility,
            images: data.imageUrl.map { [ActivityRecordImage(imageId: 0, imageUrl: $0, imageOrder: 0, imageWidth: 0, imageHeight: 0, isThumbnail: true)] } ?? []
        )
    }
}

extension DTO.UpdateRecordV2Response {
    func toDomain() -> UpdateRecordResult {
        return UpdateRecordResult(
            message: data.message,
            activityRecordId: data.activityRecordId,
            activityId: data.activityId,
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
