//
//  AIActivityItemsResponse.swift
//  Forday
//
//  Created by Subeen on 2/23/26.
//

import Foundation

extension DTO {

    /// GET /activities/ai-recommend/items
    struct AIActivityItemsResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: AIActivityItemsData?

        struct AIActivityItemsData: Codable {
            let message: String
            let hobbyId: Int
            let hobbyName: String
            let activityItems: [ActivityItemData]

            struct ActivityItemData: Codable {
                let itemId: Int
                let content: String
                let description: String
            }
        }

        func toDomain() -> AIActivityItemsResult {
            guard let data = data else {
                return AIActivityItemsResult(
                    message: "",
                    hobbyId: 0,
                    hobbyName: "",
                    activityItems: []
                )
            }

            return AIActivityItemsResult(
                message: data.message,
                hobbyId: data.hobbyId,
                hobbyName: data.hobbyName,
                activityItems: data.activityItems.map { item in
                    AIActivityItem(
                        itemId: item.itemId,
                        content: item.content,
                        description: item.description
                    )
                }
            )
        }
    }
}
