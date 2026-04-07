//
//  NotificationRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 4/3/26.
//

import Foundation

protocol NotificationRepositoryInterface {
    func updateFCMToken(fcmToken: String, deviceId: String) async throws -> Bool
    func fetchNotifications(filterType: String, lastNotificationId: String?, pageSize: Int) async throws -> NotificationList
    func toggleNotification(active: Bool, toggleType: String) async throws -> Bool
    func fetchToggleStatus() async throws -> (appPushEnabled: Bool, recordPushEnabled: Bool)
}
