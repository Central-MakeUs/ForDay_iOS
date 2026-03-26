//
//  HobbyChipsResponse.swift
//  Forday
//
//  Created by Subeen on 3/26/26.
//

import Foundation

extension DTO {

    struct HobbyChipsResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: HobbyChipsData
    }

    struct HobbyChipsData: Codable {
        let hobbyInfoList: [HobbyChipDTO]
    }

    struct HobbyChipDTO: Codable {
        let hobbyId: Int
        let hobbyName: String
        let todayRecorded: Bool
    }
}

extension DTO.HobbyChipsResponse {
    func toDomain() -> [HobbyChip] {
        return data.hobbyInfoList.map { dto in
            HobbyChip(
                hobbyId: dto.hobbyId,
                hobbyName: dto.hobbyName,
                todayRecorded: dto.todayRecorded
            )
        }
    }
}
