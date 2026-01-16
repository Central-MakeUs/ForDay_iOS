//
//  UpdateActivityResponse.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation

extension DTO {
    struct UpdateActivityResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: MessageData
    }
    
    struct MessageData: Codable {
        let message: String
    }
}

extension DTO.UpdateActivityResponse {
    func toDomain() -> String {
        return data.message
    }
}
