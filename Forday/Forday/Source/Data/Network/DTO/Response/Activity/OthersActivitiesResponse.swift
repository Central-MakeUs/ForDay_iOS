//
//  OthersActivitiesResponse.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

extension DTO {
    struct OthersActivitiesResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: OthersActivitiesData

        struct OthersActivitiesData: Codable {
            let message: String
            let activities: [ActivityItem]

            struct ActivityItem: Codable {
                let id: Int
                let content: String
            }
        }

        func toDomain() -> OthersActivityResult {
            return OthersActivityResult(
                message: data.message,
                activities: data.activities.map { item in
                    OthersActivity(
                        id: item.id,
                        content: item.content
                    )
                }
            )
        }
    }
}
