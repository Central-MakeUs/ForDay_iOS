//
//  UsersScrapsResponse.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

extension DTO {
    struct UsersScrapsResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UsersScrapsData
    }

    struct UsersScrapsData: Codable {
        let totalScrapCount: Int
        let lastScrapId: Int?
        let scrapList: [ScrapItem]
        let hasNext: Bool
    }

    struct ScrapItem: Codable {
        let scrapId: Int
        let recordId: Int
        let thumbnailImageUrl: String?
        let sticker: String
        let memo: String?
        let createdAt: String
    }
}

// MARK: - Domain Mapping

extension DTO.UsersScrapsResponse {
    func toDomain(requestedSize: Int) -> FeedResult {
        let feeds = data.scrapList.map { $0.toDomain() }

        return FeedResult(
            totalFeedCount: data.totalScrapCount,
            lastRecordId: data.lastScrapId,
            feedList: feeds,
            hasNext: data.hasNext
        )
    }
}

extension DTO.ScrapItem {
    func toDomain() -> FeedItem {
        return FeedItem(
            recordId: recordId,
            thumbnailImageUrl: thumbnailImageUrl,
            sticker: sticker,
            memo: memo,
            createdAt: createdAt
        )
    }
}
