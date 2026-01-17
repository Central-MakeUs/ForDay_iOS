//
//  CreateHobbyUseCase.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

final class CreateHobbyUseCase {

    private let repository: HobbyRepositoryInterface

    init(repository: HobbyRepositoryInterface = HobbyRepository()) {
        self.repository = repository
    }

    func execute(onboardingData: OnboardingData) async throws -> Int {
        guard let hobbyCard = onboardingData.selectedHobbyCard,
              let hobbyCardId = hobbyCard.id else {
            throw NSError(domain: "CreateHobbyUseCase", code: -1, userInfo: [NSLocalizedDescriptionKey: "취미 카드를 선택해주세요."])
        }

        let hobbyPurpose = onboardingData.purposes.joined(separator: ", ")

        return try await repository.createHobby(
            hobbyCardId: hobbyCardId,
            hobbyName: hobbyCard.name,
            hobbyTimeMinutes: onboardingData.timeMinutes,
            hobbyPurpose: hobbyPurpose,
            executionCount: onboardingData.executionCount,
            isDurationSet: onboardingData.isDurationSet
        )
    }
}
