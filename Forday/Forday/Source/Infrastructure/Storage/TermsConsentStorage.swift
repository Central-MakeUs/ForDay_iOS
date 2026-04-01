//
//  TermsConsentStorage.swift
//  Forday
//
//  Created by Subeen on 3/31/26.
//

import Foundation

/// 약관 동의 정보를 UserDefaults에 저장하는 클래스
/// 나중에 POST /terms/consent API와 연동될 예정
final class TermsConsentStorage {

    static let shared = TermsConsentStorage()

    private let userDefaults = UserDefaults.standard

    private init() {}

    private enum Key {
        static let serviceConsent = "serviceConsent"
        static let ageOver14Consent = "ageOver14Consent"
        static let privateConsent = "privateConsent"
        static let recordPushConsent = "recordPushConsent"
        static let termsConsentCompleted = "termsConsentCompleted"
    }

    // MARK: - Individual Consent

    /// 서비스 이용약관 동의 (필수)
    var serviceConsent: Bool {
        get { userDefaults.bool(forKey: Key.serviceConsent) }
        set { userDefaults.set(newValue, forKey: Key.serviceConsent) }
    }

    /// 만 14세 이상 확인 (필수)
    var ageOver14Consent: Bool {
        get { userDefaults.bool(forKey: Key.ageOver14Consent) }
        set { userDefaults.set(newValue, forKey: Key.ageOver14Consent) }
    }

    /// 개인정보 수집 및 이용 동의 (필수)
    var privateConsent: Bool {
        get { userDefaults.bool(forKey: Key.privateConsent) }
        set { userDefaults.set(newValue, forKey: Key.privateConsent) }
    }

    /// 게시글 좋아요 알림 수신 동의 (선택)
    var recordPushConsent: Bool {
        get { userDefaults.bool(forKey: Key.recordPushConsent) }
        set { userDefaults.set(newValue, forKey: Key.recordPushConsent) }
    }

    /// 약관 동의 완료 여부 (필수 3개 동의 시 true)
    var termsConsentCompleted: Bool {
        get { userDefaults.bool(forKey: Key.termsConsentCompleted) }
        set { userDefaults.set(newValue, forKey: Key.termsConsentCompleted) }
    }

    // MARK: - Save All

    /// 모든 약관 동의 정보 저장
    func saveConsents(
        serviceConsent: Bool,
        ageOver14Consent: Bool,
        privateConsent: Bool,
        recordPushConsent: Bool
    ) {
        self.serviceConsent = serviceConsent
        self.ageOver14Consent = ageOver14Consent
        self.privateConsent = privateConsent
        self.recordPushConsent = recordPushConsent

        // 필수 3개가 모두 true면 완료로 표시
        self.termsConsentCompleted = serviceConsent && ageOver14Consent && privateConsent
    }

    // MARK: - Validation

    /// 필수 약관 동의 여부 확인 (서비스, 14세, 개인정보)
    func hasRequiredConsents() -> Bool {
        return serviceConsent && ageOver14Consent && privateConsent
    }

    // MARK: - Reset (테스트용)

    /// 모든 약관 동의 정보 초기화
    func resetAllConsents() {
        userDefaults.removeObject(forKey: Key.serviceConsent)
        userDefaults.removeObject(forKey: Key.ageOver14Consent)
        userDefaults.removeObject(forKey: Key.privateConsent)
        userDefaults.removeObject(forKey: Key.recordPushConsent)
        userDefaults.removeObject(forKey: Key.termsConsentCompleted)
    }
}
