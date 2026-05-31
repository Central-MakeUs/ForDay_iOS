//
//  UpdateHobbySettingsV2UseCase.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

final class UpdateHobbySettingsV2UseCase {

    private let hobbyRepository: HobbyRepositoryInterface

    init(hobbyRepository: HobbyRepositoryInterface = HobbyRepository()) {
        self.hobbyRepository = hobbyRepository
    }

    func execute(
        progressHobbies: [(hobbyId: Int, sequence: Int)],
        hiddenHobbies: [(hobbyId: Int, sequence: Int)]
    ) async throws -> HobbySettingsV2 {
        return try await hobbyRepository.updateHobbySettingsV2(
            progressHobbies: progressHobbies,
            hiddenHobbies: hiddenHobbies
        )
    }
}
