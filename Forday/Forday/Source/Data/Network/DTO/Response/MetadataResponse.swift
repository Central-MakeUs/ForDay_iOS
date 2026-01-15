//
//  MetadataResponse.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//

import Foundation

extension DTO {
    
    struct MetadataResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: Metadata
    }
    
    struct Metadata: Codable {
        let appVersion: String
        let hobbyCards: [HobbyCard]
    }
}

extension DTO.MetadataResponse {
    func toDomain() -> AppMetadata {
        return AppMetadata(
            appVersion: data.appVersion,
            hobbyCards: data.hobbyCards.map { $0.toDomain() }
        )
    }
}

extension DTO.HobbyCard {
    func toDomain() -> HobbyCard {
        return HobbyCard(
            id: hobbyCardId,
            name: hobbyName,
            description: hobbyDescription,
            imageAsset: HobbyImageAsset(rawValue: imageCode) ?? .drawing
        )
    }
}
