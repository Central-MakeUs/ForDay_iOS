//
//  LogoutResponse.swift
//  Forday
//
//  Created by Subeen on 4/20/26.
//

extension DTO {

    struct LogoutResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: LogoutData
    }

    struct LogoutData: Codable {
        let message: String
    }
}
