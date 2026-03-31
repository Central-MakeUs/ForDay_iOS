//
//  FetchActivityDetailWithContextUseCase.swift
//  Forday
//
//  Created by Subeen on 3/31/26.
//

import Foundation

/// 활동 기록 상세 조회 UseCase (컨텍스트 기반 페이징 정보 포함)
final class FetchActivityDetailWithContextUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(activityRecordId: Int, context: ActivityDetailContext) async throws -> ActivityDetail {
        return try await repository.fetchActivityDetailV2(activityRecordId: activityRecordId, context: context)
    }
}
