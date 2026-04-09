//
//  FetchReactionTabDataResponse.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import Foundation

extension DTO {
    struct FetchReactionTabDataResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: ReactionTabDataDTO
    }
}

// MARK: - Domain Mapping

extension DTO.FetchReactionTabDataResponse {
    func toDomain() -> ReactionTabData {
        return data.toDomain()
    }
}
