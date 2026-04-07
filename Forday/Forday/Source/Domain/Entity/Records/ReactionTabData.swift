//
//  ReactionTabData.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import Foundation

/// 각 탭(전체, 멋져요, 짱이야 등)의 데이터
struct ReactionTabData {
    let users: [ReactionUserItem]
    let lastReactionId: Int?
    let hasNext: Bool
}

// MARK: - Preview

#if DEBUG
extension ReactionTabData {
    static var preview: ReactionTabData {
        ReactionTabData(
            users: ReactionUserItem.previewList,
            lastReactionId: 4,
            hasNext: true
        )
    }

    static var empty: ReactionTabData {
        ReactionTabData(
            users: [],
            lastReactionId: nil,
            hasNext: false
        )
    }
}
#endif
