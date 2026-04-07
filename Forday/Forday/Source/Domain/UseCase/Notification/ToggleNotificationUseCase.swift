//
//  ToggleNotificationUseCase.swift
//  Forday
//
//  Created by Subeen on 4/3/26.
//

import Foundation

struct ToggleNotificationUseCase {
    private let repository: NotificationRepositoryInterface
    
    init(repository: NotificationRepositoryInterface = NotificationRepository()) {
        self.repository = repository
    }
    
    func execute(active: Bool, toggleType: String = "APP") async throws -> Bool {
        return try await repository.toggleNotification(active: active, toggleType: toggleType)
    }
}
