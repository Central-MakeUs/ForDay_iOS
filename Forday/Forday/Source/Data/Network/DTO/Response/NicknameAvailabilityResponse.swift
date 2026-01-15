//
//  NicknameAvailabilityResponse.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


// Response

extension DTO {
    struct NicknameAvailabilityResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: NicknameAvailabilityData
        
        struct NicknameAvailabilityData: Codable {
            let nickname: String
            let message: String
            let available: Bool
        }
        
        func toDomain() -> NicknameCheckResult {
            return NicknameCheckResult(
                nickname: data.nickname,
                isAvailable: data.available,
                message: data.message
            )
        }
    }
}
