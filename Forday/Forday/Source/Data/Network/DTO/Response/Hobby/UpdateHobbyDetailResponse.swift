//
//  UpdateHobbyDetailResponse.swift
//  Forday
//
//  Created by Subeen on 2/25/26.
//

import Foundation

extension DTO {
    /// 온보딩 중 취미 수정 응답 (nicknameSet: false && onboardingCompleted: true 상태)
    struct UpdateHobbyDetailResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UpdateHobbyDetailData
    }

    struct UpdateHobbyDetailData: Codable {
        let hobbyId: Int
        let hobbyInfoId: Int
        let hobbyName: String
        let hobbyPurpose: String
        let hobbyTimeMinutes: Int
        let executionCount: Int
        let goalDays: Int?  // 자율모드(durationSet: false)일 경우 null
    }
}
