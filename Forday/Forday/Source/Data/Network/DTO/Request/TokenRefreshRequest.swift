//
//  TokenRefreshRequest.swift
//  Forday
//
//  Created by Claude on 1/17/26.
//

extension DTO {

    struct TokenRefreshRequest: BaseRequest {
        let refreshToken: String
    }
}
