//
//  HealthCheckResponse.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import Foundation

extension DTO {
    struct HealthCheckResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: HealthCheckData?
    }

    struct HealthCheckData: Codable {
        let message: String?
        let serverPort: Int?
        let serverEnv: String?
        let serverName: String?
    }
}
