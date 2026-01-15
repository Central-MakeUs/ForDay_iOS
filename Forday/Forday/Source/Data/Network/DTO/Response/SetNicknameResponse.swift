//
//  SetNicknameResponse.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//

// Response

extension DTO {

    struct SetNicknameResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: SetNicknameData
        
        struct SetNicknameData: Codable {
            let message: String
            let nickname: String
        }
        
        func toDomain() -> SetNicknameResult {
            return SetNicknameResult(
                nickname: data.nickname,
                message: data.message
            )
        }
    }
}
