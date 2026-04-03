//
//  HomeInfoResponse.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

extension DTO {
    struct HomeInfoResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: HomeInfoData?

        struct HomeInfoData: Codable {
            let inProgressHobbies: [InProgressHobby]
            let activityPreview: ActivityPreview?
            let greetingMessage: String
            let userSummaryText: String
            let recommendMessage: String
            let aiCallRemaining: Bool
            let aiCallRemainingCount: Int
            let unReadNotificationExists: Bool

            struct InProgressHobby: Codable {
                let hobbyId: Int
                let hobbyName: String
                let currentHobby: Bool
            }

            struct ActivityPreview: Codable {
                let activityId: Int
                let content: String
                let aiRecommended: Bool
            }

        }
    }
}

extension DTO.HomeInfoResponse {
    func toDomain() -> HomeInfo? {
        guard let data = data else {
            // No hobbies - return nil
            return nil
        }

        return HomeInfo(
            inProgressHobbies: data.inProgressHobbies.map { hobby in
                InProgressHobby(
                    hobbyId: hobby.hobbyId,
                    hobbyName: hobby.hobbyName,
                    currentHobby: hobby.currentHobby
                )
            },
            activityPreview: data.activityPreview.map { preview in
                ActivityPreview(
                    activityId: preview.activityId,
                    content: preview.content,
                    aiRecommended: preview.aiRecommended
                )
            },
            greetingMessage: data.greetingMessage,
            userSummaryText: data.userSummaryText,
            recommendMessage: data.recommendMessage,
            aiCallRemaining: data.aiCallRemaining,
            aiCallRemainingCount: data.aiCallRemainingCount
        )
    }
}
sts
        )
    }
}
