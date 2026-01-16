//
//  CreateActivitiesResponse.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation

// MARK: - Response

extension DTO {
    struct CreateActivitiesResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: CreateActivitiesData
    }
    
    struct CreateActivitiesData: Codable {
        let message: String
        let createdActivityNum: Int
    }
}

extension DTO.CreateActivitiesResponse {
    func toDomain() -> String {
        return data.message
    }
}
