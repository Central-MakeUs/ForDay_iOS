//
//  CreateHobbyV2Response.swift
//  Forday
//
//  Created by Subeen on 1/18/26.
//

import Foundation

extension DTO {
    /// v2 API: 취미 생성 응답
    struct CreateHobbyV2Response: BaseResponse {
        let status: Int
        let success: Bool
        let data: CreateHobbyV2Data
    }

    struct CreateHobbyV2Data: Codable {
        let message: String
        let createdHobbyCount: Int
        let createdHobbyInfoList: [CreatedHobbyInfo]
    }

    struct CreatedHobbyInfo: Codable {
        let hobbyId: Int
        let hobbyInfoId: Int?
        let hobbyName: String
    }
}
