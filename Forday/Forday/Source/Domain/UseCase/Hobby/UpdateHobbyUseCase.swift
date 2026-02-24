//
//  UpdateHobbyUseCase.swift
//  Forday
//
//  Created by Subeen on 2/25/26.
//

import Foundation

/// 온보딩 중 취미 수정 UseCase (nicknameSet: false && onboardingCompleted: true 상태)
final class UpdateHobbyUseCase {

    private let repository: HobbyRepositoryInterface

    init(repository: HobbyRepositoryInterface = HobbyRepository()) {
        self.repository = repository
    }

    func execute(hobbyId: Int, onboardingData: OnboardingData) async throws -> Int {
        guard let hobbyCard = onboardingData.selectedHobbyCard else {
            throw NSError(domain: "UpdateHobbyUseCase", code: -1, userInfo: [NSLocalizedDescriptionKey: "취미 카드를 선택해주세요."])
        }

        let hobbyPurpose = onboardingData.purpose

        return try await repository.updateHobby(
            hobbyId: hobbyId,
            hobbyInfoId: hobbyCard.id,
            hobbyName: hobbyCard.name,
            hobbyTimeMinutes: onboardingData.timeMinutes,
            hobbyPurpose: hobbyPurpose,
            executionCount: onboardingData.executionCount,
            isDurationSet: onboardingData.isDurationSet
        )
    }
}
