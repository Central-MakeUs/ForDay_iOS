//
//  HobbySettingsV2Response.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

extension DTO {
    struct HobbySettingsV2Response: BaseResponse {
        let status: Int
        let success: Bool
        let data: HobbySettingsV2Data
    }

    struct HobbySettingsV2Data: Codable {
        let progressHobbyList: [HobbyItemV2]
        let hiddenHobbyList: [HobbyItemV2]
    }

    struct HobbyItemV2: Codable {
        let hobbyId: Int
        let hobbyName: String
        let status: String
        let imageIcon: String
        let createdAt: String
    }
}

extension DTO.HobbySettingsV2Response {
    func toDomain() -> HobbySettingsV2 {
        let progressHobbies = data.progressHobbyList.enumerated().map { index, dto in
            HobbyItemV2Entity(
                hobbyId: dto.hobbyId,
                hobbyName: dto.hobbyName,
                status: dto.status,
                imageCode: dto.imageIcon,
                createdAt: dto.createdAt,
                sequence: index + 1
            )
        }

        let hiddenHobbies = data.hiddenHobbyList.enumerated().map { index, dto in
            HobbyItemV2Entity(
                hobbyId: dto.hobbyId,
                hobbyName: dto.hobbyName,
                status: dto.status,
                imageCode: dto.imageIcon,
                createdAt: dto.createdAt,
                sequence: index + 1
            )
        }

        return HobbySettingsV2(
            progressHobbyList: progressHobbies,
            hiddenHobbyList: hiddenHobbies
        )
    }
}
