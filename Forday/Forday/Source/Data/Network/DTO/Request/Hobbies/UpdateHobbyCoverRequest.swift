//
//  UpdateHobbyCoverRequest.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

extension DTO {
    struct UpdateHobbyCoverRequest: Codable {
        let hobbyId: Int?
        let coverImageUrl: String?
        let recordId: Int?

        // nil을 null로 명시적으로 인코딩
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(hobbyId, forKey: .hobbyId)
            try container.encode(coverImageUrl, forKey: .coverImageUrl)
            try container.encode(recordId, forKey: .recordId)
        }

        private enum CodingKeys: String, CodingKey {
            case hobbyId, coverImageUrl, recordId
        }
    }
}
