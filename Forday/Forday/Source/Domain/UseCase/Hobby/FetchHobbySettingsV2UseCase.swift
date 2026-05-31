//
//  FetchHobbySettingsV2UseCase.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

final class FetchHobbySettingsV2UseCase {

    private let hobbyRepository: HobbyRepositoryInterface

    init(hobbyRepository: HobbyRepositoryInterface = HobbyRepository()) {
        self.hobbyRepository = hobbyRepository
    }

    func execute() async throws -> HobbySettingsV2 {
        return try await hobbyRepository.fetchHobbySettingsV2()
    }
}
