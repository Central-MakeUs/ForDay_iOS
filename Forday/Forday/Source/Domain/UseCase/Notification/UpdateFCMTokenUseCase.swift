//
//  UpdateFCMTokenUseCase.swift
//  Forday
//
//  Created by Subeen on 4/3/26.
//

import Foundation

struct UpdateFCMTokenUseCase {
    private let repository: NotificationRepositoryInterface
    
    init(repository: NotificationRepositoryInterface = NotificationRepository()) {
        self.repository = repository
    }
    
    func execute(fcmToken: String, deviceId: String) async throws -> Bool {
        return try await repository.updateFCMToken(fcmToken: fcmToken, deviceId: deviceId)
    }
}
