//
//  HomeInfo.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

struct HomeInfo {
    let inProgressHobbies: [InProgressHobby]
    let activityPreview: ActivityPreview?
    let totalStickerNum: Int
    let activityRecordedToday: Bool
    let aiCallRemaining: Bool
    let collectedStickers: [CollectedSticker]
}

struct InProgressHobby {
    let hobbyId: Int
    let hobbyName: String
    let currentHobby: Bool
}

struct ActivityPreview {
    let activityId: Int
    let content: String
    let aiRecommended: Bool
}

struct CollectedSticker {
    let activityRecordId: Int
    let sticker: String
}
