//
//  Story.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

struct Story {
    let recordId: Int
    let thumbnailUrl: String?
    let stickerType: StickerType?
    let title: String
    let memo: String?
    let userInfo: StoryUserInfo
    let pressedAwesome: Bool
    let hobbyName: String?
}

struct StoryUserInfo {
    let userId: String
    let nickname: String
    let profileImageUrl: String?
}
