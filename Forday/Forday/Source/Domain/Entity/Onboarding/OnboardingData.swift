//
//  OnboardingData.swift
//  Forday
//
//  Created by Subeen on 1/13/26.
//

import Foundation

struct OnboardingData: Codable {
    var selectedHobbyCard: HobbyCard?
    var timeMinutes: Int = 10
    var purpose: String = ""
    var executionCount: Int = 0
    var isDurationSet: Bool = false

    /// 기존 취미 ID (온보딩 재개 시 updateHobby 호출용)
    /// nicknameSet: false && onboardingCompleted: true 상태에서 사용
    var existingHobbyId: Int?
}
