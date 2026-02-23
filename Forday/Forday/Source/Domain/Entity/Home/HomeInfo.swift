//
//  HomeInfo.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

struct HomeInfo {
    let inProgressHobbies: [InProgressHobby]
    let activityPreview: ActivityPreview?
    let greetingMessage: String
    let userSummaryText: String
    let recommendMessage: String
    let aiCallRemaining: Bool
    let aiCallRemainingCount: Int
}

struct InProgressHobby {
    let hobbyId: Int
    let hobbyName: String
    let currentHobby: Bool
}

struct ActivityPreview {
    let activityId: Int
    let content: String
    let aiRecommended: Bool
}
