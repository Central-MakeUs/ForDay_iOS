//
//  StoryFilterType.swift
//  Forday
//
//  Created by Subeen on 2/19/26.
//

import Foundation

/// 소식 필터 타입
enum StoryFilterType: String, CaseIterable {
    case all = "ALL"            // 전체
    case hot = "HOT"            // 지금 핫한
    case myFriend = "MY_FRIEND" // 친구

    var displayName: String {
        switch self {
        case .all: return "전체"
        case .hot: return "지금 핫한"
        case .myFriend: return "친구"
        }
    }
}
