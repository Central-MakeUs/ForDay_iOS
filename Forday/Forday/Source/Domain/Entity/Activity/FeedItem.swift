//
//  FeedItem.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import Foundation


struct FeedResult {
    let totalFeedCount: Int?
    let lastRecordId: Int?
    let feedList: [FeedItem]
    let hasNext: Bool
}

struct FeedItem {
    let recordId: Int
    let thumbnailImageUrl: String?
    let sticker: String
    let memo: String?
    let createdAt: String

    /// Converts the sticker filename string to a StickerType enum
    var stickerType: StickerType? {
        StickerType(fileName: sticker)
    }
}
