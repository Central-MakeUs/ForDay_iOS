//
//  UpdateHobbyRequest.swift
//  Forday
//
//  Created by Subeen on 2/25/26.
//

import Foundation

extension DTO {
    /// 온보딩 중 취미 수정 요청 (nicknameSet: false && onboardingCompleted: true 상태)
    struct UpdateHobbyRequest: BaseRequest {
        let hobbyInfoId: Int?
        let hobbyName: String
        let hobbyTimeMinutes: Int
        let hobbyPurpose: String
        let executionCount: Int
        let durationSet: Bool

        enum CodingKeys: String, CodingKey {
            case hobbyInfoId, hobbyName, hobbyTimeMinutes, hobbyPurpose, executionCount, durationSet
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(hobbyInfoId, forKey: .hobbyInfoId)
            try container.encode(hobbyName, forKey: .hobbyName)
            try container.encode(hobbyTimeMinutes, forKey: .hobbyTimeMinutes)
            try container.encode(hobbyPurpose, forKey: .hobbyPurpose)
            try container.encode(executionCount, forKey: .executionCount)
            try container.encode(durationSet, forKey: .durationSet)
        }
    }
}
