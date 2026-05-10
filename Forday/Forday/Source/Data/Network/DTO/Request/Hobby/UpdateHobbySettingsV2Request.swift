//
//  UpdateHobbySettingsV2Request.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

extension DTO {
    struct UpdateHobbySettingsV2Request: Codable {
        let progressHobbyList: [ProgressHobbyItem]
        let hiddenHobbyList: [HiddenHobbyItem]

        struct ProgressHobbyItem: Codable {
            let hobbyId: Int
            let sequence: Int
        }

        struct HiddenHobbyItem: Codable {
            let hobbyId: Int
            let sequence: Int
        }
    }
}
