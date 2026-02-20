//
//  ReportRecordResponse.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import Foundation

extension DTO {
    struct ReportRecordResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: ReportRecordData?
    }

    struct ReportRecordData: Codable {
        let message: String?
    }
}
