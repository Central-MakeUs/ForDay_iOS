//
//  StoriesResponse.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

extension DTO {

    struct StoriesResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: StoriesData?
    }

    struct StoriesData: Codable {
        let unReadNotificationExists: Bool
        let tabInfo: [StoriesTabInfo]?
        let lastRecordId: Int?
        let recordList: [StoryInfo]
        let hasNext: Bool
    }

    struct StoriesTabInfo: Codable {
        let hobbyId: Int
        let hobbyName: String
        let currentHobby: Bool
    }

    struct StoryInfo: Codable {
        let recordId: Int
        let thumbnailUrl: String?
        let sticker: String?
        let title: String
        let memo: String?
        let userInfo: StoryUserInfo
        let pressedAweSome: Bool
        let hobbyName: String?
    }

    struct StoryUserInfo: Codable {
        let userId: String
        let nickname: String?
        let profileImageUrl: String?
    }
}

extension DTO.StoriesResponse {
    func toDomain() -> StoriesResult? {
        guard let data = data else { return nil }
        return data.toDomain()
    }
}

extension DTO.StoriesData {
    func toDomain() -> StoriesResult {
        return StoriesResult(
            tabs: tabInfo?.map { $0.toDomain() } ?? [],
            stories: recordList.map { $0.toDomain() },
            lastRecordId: lastRecordId,
            hasNext: hasNext,
            unReadNotificationExists: unReadNotificationExists
        )
    }
}

extension DTO.StoriesTabInfo {
    func toDomain() -> StoriesTab {
        return StoriesTab(
            hobbyId: hobbyId,
            hobbyName: hobbyName,
            currentHobby: currentHobby
        )
    }
}

extension DTO.StoryInfo {
    func toDomain() -> Story {
        return Story(
            recordId: recordId,
            thumbnailUrl: thumbnailUrl,
            stickerType: sticker.flatMap { StickerType(rawValue: $0) },
            title: title,
            memo: memo,
            userInfo: userInfo.toDomain(),
            pressedAwesome: pressedAweSome,
            hobbyName: hobbyName
        )
    }
}

extension DTO.StoryUserInfo {
    func toDomain() -> StoryUserInfo {
        return StoryUserInfo(
            userId: userId,
            nickname: nickname ?? "익명",
            profileImageUrl: profileImageUrl
        )
    }
}
