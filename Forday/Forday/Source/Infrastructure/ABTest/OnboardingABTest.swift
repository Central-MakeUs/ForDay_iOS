//
//  OnboardingABTest.swift
//  Forday
//
//  Created by Subeen on 1/18/26.
//

import Foundation
import FirebaseRemoteConfig
import FirebaseAnalytics

/// 온보딩 플로우 AB 테스트 관리
final class OnboardingABTest {

    enum Group: String {
        case control = "OLD"  // 기존 플로우 (취미 생성 상세 입력)
        case variant = "NEW"  // 신규 플로우 (간소화된 취미 선택)
    }

    private static let userDefaultsKey = "OnboardingABTestGroup"
    private static let remoteConfigKey = "onboarding_variant"

    /// 현재 사용자의 AB 테스트 그룹 가져오기 (Firebase Remote Config 사용)
    static func getGroup(completion: @escaping (Group) -> Void) {
        // 1. 이미 배정된 그룹이 있는지 확인 (캐시)
        if let savedGroupRawValue = UserDefaults.standard.string(forKey: userDefaultsKey),
           let savedGroup = Group(rawValue: savedGroupRawValue) {
            print("🧪 [AB Test] 기존 그룹 사용: \(savedGroup.rawValue)")
            completion(savedGroup)
            return
        }

        // 2. Firebase Remote Config에서 그룹 가져오기
        let remoteConfig = RemoteConfig.remoteConfig()

        // Remote Config 설정 (개발 중에는 fetch interval을 짧게 설정)
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0  // 디버그 모드에서는 즉시 fetch
        #else
        settings.minimumFetchInterval = 3600  // 프로덕션에서는 1시간
        #endif
        remoteConfig.configSettings = settings

        // Remote Config fetch 및 활성화
        remoteConfig.fetchAndActivate { status, error in
            var assignedGroup: Group

            if let error = error {
                print("⚠️ [AB Test] Remote Config fetch 실패: \(error.localizedDescription)")
                // Fallback: 로컬 랜덤 배정
                assignedGroup = assignGroupLocally()
            } else {
                // Remote Config에서 값 가져오기
                let groupValue = remoteConfig.configValue(forKey: remoteConfigKey).stringValue ?? "OLD"
                assignedGroup = Group(rawValue: groupValue) ?? .control

                print("🧪 [AB Test] Firebase에서 그룹 할당: \(assignedGroup.rawValue)")
            }

            // 3. UserDefaults에 저장 (캐싱)
            UserDefaults.standard.set(assignedGroup.rawValue, forKey: userDefaultsKey)

            // 4. Firebase Analytics 이벤트 로깅
            Analytics.logEvent("ab_test_group_assigned", parameters: [
                "group": assignedGroup.rawValue,
                "test_name": "onboarding_flow"
            ])

            completion(assignedGroup)
        }
    }

    /// 동기 방식 그룹 가져오기 (캐시된 값만 사용)
    /// - Note: 최초 실행 시에는 `getGroup(completion:)`을 먼저 호출해야 함
    static func getCachedGroup() -> Group {
        if let savedGroupRawValue = UserDefaults.standard.string(forKey: userDefaultsKey),
           let savedGroup = Group(rawValue: savedGroupRawValue) {
            return savedGroup
        }

        // 캐시가 없으면 control(기존 플로우)을 기본값으로 반환
        print("⚠️ [AB Test] 캐시된 그룹 없음, control을 기본값으로 사용")
        return .control
    }

    /// 로컬 랜덤 배정 (Firebase fetch 실패 시 fallback)
    private static func assignGroupLocally() -> Group {
        let randomGroup: Group = Bool.random() ? .control : .variant
        print("🧪 [AB Test] 로컬 랜덤 배정: \(randomGroup.rawValue)")
        return randomGroup
    }

    /// 온보딩 완료 이벤트 로깅 (A/B 테스트 목표 측정)
    static func logOnboardingCompleted() {
        let group = getCachedGroup()
        Analytics.logEvent("onboarding_completed", parameters: [
            "group": group.rawValue,
            "test_name": "onboarding_flow"
        ])
        print("📊 [AB Test] 온보딩 완료 이벤트 로깅: \(group.rawValue)")
    }

    /// AB 테스트 그룹 초기화 (테스트/디버깅용)
    static func resetGroup() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        print("🧪 [AB Test] 그룹 초기화됨")
    }
}
