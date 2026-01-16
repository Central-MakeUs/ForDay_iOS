//
//  TokenRefreshResponse.swift
//  Forday
//
//  Created by Claude on 1/17/26.
//

extension DTO {

    struct TokenRefreshResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: TokenRefreshData
    }

    struct TokenRefreshData: Codable {
        let accessToken: String
        let refreshToken: String
    }
}
