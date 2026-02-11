//
//  HomeInfo+Fixture.swift
//  FordayTests
//
//  Created by Subeen on 2/10/26.
//

import Foundation
@testable import Forday

extension HomeInfo {

    static func fixture(
        inProgressHobbies: [InProgressHobby] = [],
        activityPreview: ActivityPreview? = nil,
        greetingMessage: String = "안녕하세요!",
        userSummaryText: String = "",
        recommendMessage: String = "",
        aiCallRemaining: Bool = true
    ) -> HomeInfo {
        return HomeInfo(
            inProgressHobbies: inProgressHobbies,
            activityPreview: activityPreview,
            greetingMessage: greetingMessage,
            userSummaryText: userSummaryText,
            recommendMessage: recommendMessage,
            aiCallRemaining: aiCallRemaining
        )
    }

    static var sample: HomeInfo {
        return HomeInfo(
            inProgressHobbies: [
                .sample,
                InProgressHobby(hobbyId: 2, hobbyName: "독서", currentHobby: false)
            ],
            activityPreview: .sample,
            greetingMessage: "좋은 아침이에요!",
            userSummaryText: "3일째 열심히 하고 있어요",
            recommendMessage: "오늘도 화이팅!",
            aiCallRemaining: true
        )
    }

    static var empty: HomeInfo {
        return HomeInfo(
            inProgressHobbies: [],
            activityPreview: nil,
            greetingMessage: "취미를 시작해보세요!",
            userSummaryText: "",
            recommendMessage: "새로운 취미를 등록해보세요",
            aiCallRemaining: true
        )
    }
}

extension InProgressHobby {

    static func fixture(
        hobbyId: Int = 1,
        hobbyName: String = "그림",
        currentHobby: Bool = true
    ) -> InProgressHobby {
        return InProgressHobby(
            hobbyId: hobbyId,
            hobbyName: hobbyName,
            currentHobby: currentHobby
        )
    }

    static var sample: InProgressHobby {
        return InProgressHobby(
            hobbyId: 1,
            hobbyName: "그림",
            currentHobby: true
        )
    }
}

extension ActivityPreview {

    static func fixture(
        activityId: Int = 1,
        content: String = "오늘 30분 연습",
        aiRecommended: Bool = false
    ) -> ActivityPreview {
        return ActivityPreview(
            activityId: activityId,
            content: content,
            aiRecommended: aiRecommended
        )
    }

    static var sample: ActivityPreview {
        return ActivityPreview(
            activityId: 100,
            content: "오늘 30분 그림 연습했어요",
            aiRecommended: false
        )
    }
}
