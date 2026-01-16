//
//  TokenValidateResponse.swift
//  Forday
//
//  Created by Claude on 1/17/26.
//

extension DTO {

    struct TokenValidateResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: TokenValidateData
    }

    struct TokenValidateData: Codable {
        let tokenValid: Bool
    }
}
