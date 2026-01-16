//
//  CreateHobbyRequest.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

extension DTO {
    struct CreateHobbyRequest: BaseRequest {
        let hobbyCardId: Int
        let hobbyName: String
        let hobbyTimeMinutes: Int
        let hobbyPurpose: String
        let executionCount: Int
        let isDurationSet: Bool
    }
}
