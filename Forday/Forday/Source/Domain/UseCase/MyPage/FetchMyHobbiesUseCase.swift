//
//  FetchMyHobbiesUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchMyHobbiesUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    /// 사용자 취미 진행 상태 조회 (userId가 nil이면 본인)
    func execute(userId: String? = nil) async throws -> MyHobbiesResult {
        return try await repository.fetchMyHobbies(userId: userId)
    }
}
