//
//  ActivityRecordV2.swift
//  Forday
//
//  Created by Subeen on 6/27/26.
//

import Foundation

/// 활동 기록 V2 응답 Entity
struct ActivityRecordV2 {
    let activityRecordId: Int
    let hobbyName: String
    let activityContent: String
    let sticker: String
    let memo: String?
    let visibility: String
    let images: [ActivityRecordImage]
}

/// 활동 기록 이미지 정보
struct ActivityRecordImage {
    let imageId: Int
    let imageUrl: String
    let imageOrder: Int
    let imageWidth: Int
    let imageHeight: Int
    let isThumbnail: Bool
}
