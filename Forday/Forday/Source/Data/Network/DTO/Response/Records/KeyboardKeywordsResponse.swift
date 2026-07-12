//
//  KeyboardKeywordsResponse.swift
//  Forday
//
//  Created by Subeen on 7/8/26.
//

import Foundation

extension DTO {
    /// 키보드 키워드 조회 응답
    /// - Endpoint: GET /api/v2/records/keyboard-keywords
    struct KeyboardKeywordsResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: KeyboardKeywordsData
    }

    struct KeyboardKeywordsData: Codable {
        let hobbyInfoId: Int
        let keywords: [KeywordItem]
    }

    struct KeywordItem: Codable {
        let keywordId: Int
        let keyword: String
    }
}

// MARK: - Domain Mapping

extension DTO.KeyboardKeywordsResponse {
    func toDomain() -> [KeyboardKeyword] {
        return data.keywords.map { item in
            KeyboardKeyword(
                keywordId: item.keywordId,
                keyword: item.keyword
            )
        }
    }
}
