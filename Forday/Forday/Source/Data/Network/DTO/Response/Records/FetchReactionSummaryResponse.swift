//
//  FetchReactionSummaryResponse.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import Foundation

extension DTO {
    struct FetchReactionSummaryResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: ReactionSummaryData
    }

    struct ReactionSummaryData: Codable {
        let reactionSummary: ReactionSummaryDTO
        let tabs: ReactionTabsDTO
    }

    struct ReactionSummaryDTO: Codable {
        let totalCount: Int
        let awesome: Int
        let great: Int
        let amazing: Int
        let fighting: Int
    }

    struct ReactionTabsDTO: Codable {
        let all: ReactionTabDataDTO
        let awesome: ReactionTabDataDTO
        let great: ReactionTabDataDTO
        let amazing: ReactionTabDataDTO
        let fighting: ReactionTabDataDTO

        enum CodingKeys: String, CodingKey {
            case all = "ALL"
            case awesome = "AWESOME"
            case great = "GREAT"
            case amazing = "AMAZING"
            case fighting = "FIGHTING"
        }
    }

    struct ReactionTabDataDTO: Codable {
        let users: [ReactionUserItemDTO]
        let lastReactionId: Int?
        let hasNext: Bool
    }

    struct ReactionUserItemDTO: Codable {
        let reactionId: Int
        let userId: String
        let nickname: String
        let profileImageUrl: String?
        let reactionType: String
    }
}

// MARK: - Domain Mapping

extension DTO.FetchReactionSummaryResponse {
    func toDomain(recordId: Int) -> ReactionSummaryResponse {
        return ReactionSummaryResponse(
            recordId: recordId,
            reactionSummary: data.reactionSummary.toDomain(),
            tabs: data.tabs.toDomain()
        )
    }
}

extension DTO.ReactionSummaryDTO {
    func toDomain() -> ReactionSummary {
        return ReactionSummary(
            totalCount: totalCount,
            awesome: awesome,
            great: great,
            amazing: amazing,
            fighting: fighting
        )
    }
}

extension DTO.ReactionTabsDTO {
    func toDomain() -> ReactionTabs {
        return ReactionTabs(
            all: all.toDomain(),
            awesome: awesome.toDomain(),
            great: great.toDomain(),
            amazing: amazing.toDomain(),
            fighting: fighting.toDomain()
        )
    }
}

extension DTO.ReactionTabDataDTO {
    func toDomain() -> ReactionTabData {
        return ReactionTabData(
            users: users.map { $0.toDomain() },
            lastReactionId: lastReactionId,
            hasNext: hasNext
        )
    }
}

extension DTO.ReactionUserItemDTO {
    func toDomain() -> ReactionUserItem {
        return ReactionUserItem(
            reactionId: reactionId,
            userId: userId,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            reactionType: ReactionType(rawValue: reactionType) ?? .awesome
        )
    }
}
