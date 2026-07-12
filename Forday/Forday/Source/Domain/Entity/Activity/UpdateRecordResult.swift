//
//  UpdateRecordResult.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

struct UpdateRecordResult {
    let message: String
    let activityRecordId: Int?
    let activityId: Int
    let activityContent: String
    let sticker: String
    let memo: String?
    let visibility: String
    let images: [ActivityRecordImage]
}
