//
//  FetchActivityDetailUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

/// 활동 기록 단일 상세 조회 UseCase (페이징 정보 없음)
final class FetchActivityDetailUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(activityRecordId: Int) async throws -> ActivityDetail {
        return try await repository.fetchActivityDetail(activityRecordId: activityRecordId)
    }
}
