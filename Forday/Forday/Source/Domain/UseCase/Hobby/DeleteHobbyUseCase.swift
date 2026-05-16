//
//  DeleteHobbyUseCase.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

final class DeleteHobbyUseCase {

    private let hobbyRepository: HobbyRepositoryInterface

    init(hobbyRepository: HobbyRepositoryInterface = HobbyRepository()) {
        self.hobbyRepository = hobbyRepository
    }

    func execute(hobbyId: Int) async throws -> String {
        return try await hobbyRepository.deleteHobby(hobbyId: hobbyId)
    }
}
