//
//  CreateHobbyResponse.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

extension DTO {
    struct CreateHobbyResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: CreateHobbyData
    }
    
    struct CreateHobbyData: Codable {
        let message: String
        let hobbyId: Int
    }
}
