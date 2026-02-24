//
//  FetchHobbyCardsUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchHobbyCardsUseCase {

    private let repository: UsersRepositoryInterface

    init(repository: UsersRepositoryInterface = UsersRepository()) {
        self.repository = repository
    }

    /// 사용자 취미 카드 조회 (userId가 nil이면 본인)
    func execute(lastHobbyCardId: Int?, size: Int = 20, userId: String? = nil) async throws -> HobbyCardsResult {
        return try await repository.fetchHobbyCards(lastHobbyCardId: lastHobbyCardId, size: size, userId: userId)
    }
}
