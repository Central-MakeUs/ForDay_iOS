//
//  FetchActivityDetailUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchActivityDetailUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(activityRecordId: Int, context: ActivityDetailContext? = nil) async throws -> ActivityDetail {
        return try await repository.fetchActivityDetail(activityRecordId: activityRecordId, context: context)
    }
}
