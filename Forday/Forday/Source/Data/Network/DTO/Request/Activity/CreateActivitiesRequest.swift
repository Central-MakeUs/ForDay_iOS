//
//  CreateActivitiesRequest.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation

extension DTO {
    struct CreateActivitiesRequest: BaseRequest {
        let activities: [ActivityInput]
    }
    
    struct ActivityInput: Codable {
        let aiRecommended: Bool
        let content: String
        
        enum CodingKeys: String, CodingKey {
            case aiRecommended = "ai_recommended"
            case content
        }
    }
}
