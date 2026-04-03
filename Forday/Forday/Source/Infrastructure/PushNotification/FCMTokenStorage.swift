//
//  FCMTokenStorage.swift
//  Forday
//
//  Created by Subeen on 4/3/26.
//

import Foundation

final class FCMTokenStorage {

    static let shared = FCMTokenStorage()
    private let userDefaults = UserDefaults.standard

    private init() {}

    private enum Key {
        static let fcmToken = "fcmToken"
        static let deviceId = "deviceId"
    }

    // MARK: - Save

    func saveFCMToken(_ token: String) {
        userDefaults.set(token, forKey: Key.fcmToken)
        print("💾 [FCMTokenStorage] FCM Token saved")
    }

    func saveDeviceId(_ deviceId: String) {
        userDefaults.set(deviceId, forKey: Key.deviceId)
        print("💾 [FCMTokenStorage] Device ID saved")
    }

    func saveTokenInfo(fcmToken: String, deviceId: String) {
        saveFCMToken(fcmToken)
        saveDeviceId(deviceId)
    }

    // MARK: - Load

    func loadFCMToken() -> String? {
        return userDefaults.string(forKey: Key.fcmToken)
    }

    func loadDeviceId() -> String? {
        return userDefaults.string(forKey: Key.deviceId)
    }

    // MARK: - Delete

    func deleteFCMToken() {
        userDefaults.removeObject(forKey: Key.fcmToken)
        print("🗑️ [FCMTokenStorage] FCM Token deleted")
    }

    func deleteDeviceId() {
        userDefaults.removeObject(forKey: Key.deviceId)
        print("🗑️ [FCMTokenStorage] Device ID deleted")
    }

    func deleteAll() {
        deleteFCMToken()
        deleteDeviceId()
    }
}
