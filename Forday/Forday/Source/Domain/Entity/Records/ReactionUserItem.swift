//
//  ReactionUserItem.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import Foundation

/// 감정 반응 목록 조회 API에서 사용하는 유저 정보
struct ReactionUserItem {
    let reactionId: Int
    let userId: String
    let nickname: String
    let profileImageUrl: String?
    let reactionType: ReactionType
}

// MARK: - Preview

#if DEBUG
extension ReactionUserItem {
    static var preview: ReactionUserItem {
        ReactionUserItem(
            reactionId: 1,
            userId: "user1",
            nickname: "닉네임입니다",
            profileImageUrl: nil,
            reactionType: .awesome
        )
    }

    static var previewList: [ReactionUserItem] {
        [
            ReactionUserItem(reactionId: 1, userId: "user1", nickname: "유저1", profileImageUrl: nil, reactionType: .awesome),
            ReactionUserItem(reactionId: 2, userId: "user2", nickname: "유저2", profileImageUrl: nil, reactionType: .great),
            ReactionUserItem(reactionId: 3, userId: "user3", nickname: "유저3", profileImageUrl: nil, reactionType: .amazing),
            ReactionUserItem(reactionId: 4, userId: "user4", nickname: "유저4", profileImageUrl: nil, reactionType: .fighting)
        ]
    }
}
#endif
