//
//  HobbySettingsV2.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

struct HobbySettingsV2 {
    let progressHobbyList: [HobbyItemV2Entity]
    let hiddenHobbyList: [HobbyItemV2Entity]
}

struct HobbyItemV2Entity {
    let hobbyId: Int
    let hobbyName: String
    let status: String
    let imageCode: String
    let createdAt: String
    let sequence: Int? // progressHobbyList에서만 사용

    /// imageCode를 HobbyImageAsset으로 변환
    var imageAsset: HobbyImageAsset {
        return HobbyImageAsset(imageCode: imageCode) ?? .reading
    }
}
