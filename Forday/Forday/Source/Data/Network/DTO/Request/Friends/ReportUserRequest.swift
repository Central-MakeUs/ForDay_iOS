//
//  ReportUserRequest.swift
//  Forday
//
//  Created by Subeen on 3/6/26.
//

import Foundation

extension DTO {
    struct ReportUserRequest: Codable {
        let userId: String
        let reason: String
    }
}
