//
//  CreateHobbyV2Request.swift
//  Forday
//
//  Created by Subeen on 1/18/26.
//

import Foundation

extension DTO {
    /// v2 API: 취미 생성 요청 (여러 개 한번에)
    struct CreateHobbyV2Request: BaseRequest {
        let hobbyList: [HobbyItem]

        struct HobbyItem: Codable {
            let hobbyInfoId: Int?
            let hobbyName: String
        }
    }
}
