//
//  ReportUserResponse.swift
//  Forday
//
//  Created by Subeen on 3/6/26.
//

import Foundation

extension DTO {
    struct ReportUserResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: ReportUserData?
    }

    struct ReportUserData: Codable {
        let message: String
        let nickname: String
        let userId: String
    }
}
