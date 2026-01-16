//
//  Activity.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation

struct Activity {
    let activityId: Int
    let content: String
    let aiRecommended: Bool
    let deletable: Bool
    let stickers: [ActivitySticker]
    
    var hasStickers: Bool {
        return !stickers.isEmpty
    }
}

struct ActivitySticker {
    let activityRecordId: Int
    let sticker: String
}
