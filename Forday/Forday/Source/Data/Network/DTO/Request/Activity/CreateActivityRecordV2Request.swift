//
//  CreateActivityRecordV2Request.swift
//  Forday
//
//  Created by Subeen on 6/27/26.
//

import Foundation

extension DTO {
    /// 활동 기록하기 V2 API Request
    /// - Note: activityId와 activityContent는 둘 중 하나만 입력
    ///   - activityId가 있는 경우: 기존 활동을 사용하여 기록 (activityContent는 null)
    ///   - activityContent가 있는 경우: 새 활동을 생성한 뒤 기록 (activityId는 null)
    struct CreateActivityRecordV2Request: BaseRequest {
        let hobbyId: Int
        let activityId: Int?
        let activityContent: String?
        let sticker: String
        let images: [ImageInput]
        let visibility: String
        let memo: String?
        let activityContentValid: Bool
    }

    /// 이미지 입력 정보
    struct ImageInput: Codable {
        let imageUrl: String
        let imageOrder: Int
        let imageWidth: Int
        let imageHeight: Int
    }
}
