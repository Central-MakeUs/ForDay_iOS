//
//  AppLaunchStorage.swift
//  Forday
//
//  Created by Subeen on 2/26/26.
//

import Foundation

/// 앱 실행 관련 상태를 UserDefaults에 저장하는 클래스
final class AppLaunchStorage {

    static let shared = AppLaunchStorage()

    private let userDefaults = UserDefaults.standard

    private init() {}

    private enum Key {
        static let hasSeenAppIntro = "hasSeenAppIntro"
    }

    // MARK: - App Intro

    /// 앱 소개 화면을 본 적이 있는지 여부
    var hasSeenAppIntro: Bool {
        get { userDefaults.bool(forKey: Key.hasSeenAppIntro) }
        set { userDefaults.set(newValue, forKey: Key.hasSeenAppIntro) }
    }

    /// 앱 소개 화면을 봤음으로 표시
    func markAppIntroAsSeen() {
        hasSeenAppIntro = true
    }

    /// 앱 소개 상태 초기화 (테스트용)
    func resetAppIntroStatus() {
        hasSeenAppIntro = false
    }
}
