//
//  UpdateRecordRequest.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

extension DTO {
    /// 활동 기록 수정 V1 Request (단일 이미지)
    struct UpdateRecordRequest: BaseRequest {
        let activityId: Int
        let sticker: String
        let memo: String?
        let imageUrl: String?
        let visibility: String
    }

    /// 활동 기록 수정 V2 Request (다중 이미지)
    /// - Note: activityId를 생략하면 기존 활동을 유지합니다.
    struct UpdateRecordV2Request: BaseRequest {
        let activityId: Int?
        let sticker: String
        let memo: String?
        let images: [ImageInput]
        let visibility: String
    }
}
