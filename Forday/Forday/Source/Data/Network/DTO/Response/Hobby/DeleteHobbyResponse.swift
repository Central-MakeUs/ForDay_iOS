//
//  DeleteHobbyResponse.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

extension DTO {
    struct DeleteHobbyResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: DeleteHobbyData
    }

    struct DeleteHobbyData: Codable {
        let hobbyId: Int
        let message: String
    }
}
