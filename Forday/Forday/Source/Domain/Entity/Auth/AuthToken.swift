//
//  AuthToken.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

struct AuthToken {
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
    let socialType: SocialType
    let guestUserId: String?
    let onboardingCompleted: Bool
    let nicknameSet: Bool
    let onboardingData: SavedOnboardingData?
    let termsConsentCompleted: Bool
}

struct SavedOnboardingData {
    let id: Int
    let hobbyInfoId: Int
    let hobbyName: String
    let hobbyPurpose: String
    let hobbyTimeMinutes: Int
    let executionCount: Int
    let durationSet: Bool
}
