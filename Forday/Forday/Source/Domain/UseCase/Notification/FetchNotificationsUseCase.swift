//
//  FetchNotificationsUseCase.swift
//  Forday
//
//  Created by Subeen on 4/3/26.
//

import Foundation

struct FetchNotificationsUseCase {
    private let repository: NotificationRepositoryInterface
    
    init(repository: NotificationRepositoryInterface = NotificationRepository()) {
        self.repository = repository
    }
    
    func execute(filterType: String = "ALL", lastNotificationId: String? = nil, pageSize: Int = 20) async throws -> NotificationList {
        return try await repository.fetchNotifications(
            filterType: filterType,
            lastNotificationId: lastNotificationId,
            pageSize: pageSize
        )
    }
}
