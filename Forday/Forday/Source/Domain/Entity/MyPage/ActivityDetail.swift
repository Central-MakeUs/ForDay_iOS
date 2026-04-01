//
//  ActivityDetail.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

struct ActivityDetail {
    let activityRecordId: Int
    let hobbyId: Int
    let hobbyName: String
    let activityId: Int
    let activityContent: String
    let imageUrl: String
    let sticker: String
    let createdAt: String
    let memo: String
    let recordOwner: Bool
    let scraped: Bool
    let userInfo: ActivityDetailUserInfo?
    let visibility: String
    let newReaction: ReactionStatus
    let userReaction: ReactionStatus
    let prevRecordId: Int?  // 이전 기록 ID (페이징용)
    let nextRecordId: Int?  // 다음 기록 ID (페이징용)
}

struct ActivityDetailUserInfo {
    let userId: String
    let nickname: String
    let profileImageUrl: String?
}

// MARK: - Preview

#if DEBUG
extension ActivityDetailUserInfo {
    static var preview: ActivityDetailUserInfo {
        ActivityDetailUserInfo(
            userId: "user-001",
            nickname: "러너",
            profileImageUrl: nil
        )
    }

    static var previewWithImage: ActivityDetailUserInfo {
        ActivityDetailUserInfo(
            userId: "user-002",
            nickname: "달리기",
            profileImageUrl: "https://picsum.photos/200/200"
        )
    }
}

extension ActivityDetail {
    static var preview: ActivityDetail {
        ActivityDetail(
            activityRecordId: 1,
            hobbyId: 1,
            hobbyName: "러닝",
            activityId: 1,
            activityContent: "아침 러닝 10km",
            imageUrl: "https://picsum.photos/300/300",
            sticker: "sticker_awesome_big",
            createdAt: "2026.01.15",
            memo: "오늘은 날씨가 좋아서 기분 좋게 달렸어요!",
            recordOwner: true,
            scraped: false,
            userInfo: .preview,
            visibility: "PUBLIC",
            newReaction: .previewNone,
            userReaction: .preview,
            prevRecordId: nil,
            nextRecordId: 2
        )
    }

    static var previewScraped: ActivityDetail {
        ActivityDetail(
            activityRecordId: 2,
            hobbyId: 1,
            hobbyName: "요가",
            activityId: 2,
            activityContent: "저녁 요가 60분",
            imageUrl: "https://picsum.photos/300/300",
            sticker: "sticker_great_big",
            createdAt: "2026.01.20",
            memo: "스트레칭 위주로 진행했습니다.",
            recordOwner: true,
            scraped: true,
            userInfo: .previewWithImage,
            visibility: "FRIENDS_ONLY",
            newReaction: .preview,
            userReaction: .previewNone,
            prevRecordId: 1,
            nextRecordId: 3
        )
    }

    static var previewWithAllReactions: ActivityDetail {
        ActivityDetail(
            activityRecordId: 3,
            hobbyId: 2,
            hobbyName: "음악 듣기",
            activityId: 3,
            activityContent: "기타 연습 2시간",
            imageUrl: "https://picsum.photos/300/300",
            sticker: "sticker_amazing_big",
            createdAt: "2026.01.25",
            memo: "새로운 곡을 배웠어요. 어려웠지만 재미있었습니다!",
            recordOwner: false,
            scraped: false,
            userInfo: .preview,
            visibility: "PUBLIC",
            newReaction: .previewAll,
            userReaction: .previewAll,
            prevRecordId: 2,
            nextRecordId: 4
        )
    }

    static var previewOthersActivity: ActivityDetail {
        ActivityDetail(
            activityRecordId: 4,
            hobbyId: 3,
            hobbyName: "독서",
            activityId: 4,
            activityContent: "독서 1시간",
            imageUrl: "https://picsum.photos/300/300",
            sticker: "sticker_fighting_big",
            createdAt: "2026.01.28",
            memo: "",
            recordOwner: false,
            scraped: true,
            userInfo: .previewWithImage,
            visibility: "PRIVATE",
            newReaction: .preview,
            userReaction: .previewNone,
            prevRecordId: 3,
            nextRecordId: nil
        )
    }
}
#endif
