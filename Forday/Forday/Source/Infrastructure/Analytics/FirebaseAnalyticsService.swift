//
//  FirebaseAnalyticsService.swift
//  Forday
//
//  Created by Subeen on 3/5/26.
//

import Foundation
import FirebaseAnalytics

/// Firebase Analytics 구현체
final class FirebaseAnalyticsService: AnalyticsService {

    static let shared = FirebaseAnalyticsService()

    private init() {}

    func log(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)

        #if DEBUG
        print("📊 [Analytics] \(event.name)")
        if let params = event.parameters {
            print("   Parameters: \(params)")
        }
        #endif
    }

    func setUserProperty(value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)

        #if DEBUG
        print("👤 [Analytics] User Property: \(name) = \(value ?? "nil")")
        #endif
    }

    func setUserID(_ userID: String?) {
        Analytics.setUserID(userID)

        #if DEBUG
        print("🆔 [Analytics] User ID: \(userID ?? "nil")")
        #endif
    }
}
