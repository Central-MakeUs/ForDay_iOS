//
//  HomeInfoResponse.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

extension DTO {
    struct HomeInfoResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: HomeInfoData

        struct HomeInfoData: Codable {
            let inProgressHobbies: [InProgressHobby]
            let activityPreview: ActivityPreview?
            let totalStickerNum: Int
            let activityRecordedToday: Bool
            let aiCallRemaining: Bool
            let collectedStickers: [CollectedSticker]

            struct InProgressHobby: Codable {
                let hobbyId: Int
                let hobbyName: String
                let currentHobby: Bool
            }

            struct ActivityPreview: Codable {
                let activityId: Int
                let content: String
                let aiRecommended: Bool
            }

            struct CollectedSticker: Codable {
                let activityRecordId: Int
                let sticker: String
            }
        }

        func toDomain() -> HomeInfo {
            return HomeInfo(
                inProgressHobbies: data.inProgressHobbies.map { hobby in
                    InProgressHobby(
                        hobbyId: hobby.hobbyId,
                        hobbyName: hobby.hobbyName,
                        currentHobby: hobby.currentHobby
                    )
                },
                activityPreview: data.activityPreview.map { preview in
                    ActivityPreview(
                        activityId: preview.activityId,
                        content: preview.content,
                        aiRecommended: preview.aiRecommended
                    )
                },
                totalStickerNum: data.totalStickerNum,
                activityRecordedToday: data.activityRecordedToday,
                aiCallRemaining: data.aiCallRemaining,
                collectedStickers: data.collectedStickers.map { sticker in
                    CollectedSticker(
                        activityRecordId: sticker.activityRecordId,
                        sticker: sticker.sticker
                    )
                }
            )
        }
    }
}
