//
//  FetchNotificationToggleStatusUseCase.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import Foundation

struct FetchNotificationToggleStatusUseCase {
    private let repository: NotificationRepositoryInterface

    init(repository: NotificationRepositoryInterface = NotificationRepository()) {
        self.repository = repository
    }

    func execute() async throws -> (appPushEnabled: Bool, recordPushEnabled: Bool) {
        return try await repository.fetchToggleStatus()
    }
}
