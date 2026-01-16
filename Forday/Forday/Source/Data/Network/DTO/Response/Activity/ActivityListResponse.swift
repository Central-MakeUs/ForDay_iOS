//
//  ActivityListResponse.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation

extension DTO {
    struct ActivityListResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: ActivityListData
    }
    
    struct ActivityListData: Codable {
        let activities: [ActivityData]
    }
    
    struct ActivityData: Codable {
        let activityId: Int
        let content: String
        let aiRecommended: Bool
        let deletable: Bool
        let stickers: [StickerData]
    }
    
    struct StickerData: Codable {
        let activityRecordId: Int
        let sticker: String
    }
}

// MARK: - BaseResponse

extension DTO.ActivityListResponse {
    func toDomain() -> [Activity] {
        return data.activities.map { $0.toDomain() }
    }
}

extension DTO.ActivityData {
    func toDomain() -> Activity {
        return Activity(
            activityId: activityId,
            content: content,
            aiRecommended: aiRecommended,
            deletable: deletable,
            stickers: stickers.map { $0.toDomain() }
        )
    }
}

extension DTO.StickerData {
    func toDomain() -> ActivitySticker {
        return ActivitySticker(
            activityRecordId: activityRecordId,
            sticker: sticker
        )
    }
}
