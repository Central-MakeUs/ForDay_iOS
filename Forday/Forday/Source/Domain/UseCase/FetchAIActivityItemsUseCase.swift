//
//  FetchAIActivityItemsUseCase.swift
//  Forday
//
//  Created by Subeen on 2/23/26.
//

import Foundation

struct FetchAIActivityItemsUseCase {

    private let activityRepository: ActivityRepositoryInterface

    init(activityRepository: ActivityRepositoryInterface = ActivityRepository()) {
        self.activityRepository = activityRepository
    }

    /// type: "ALL" - 전체 조회, "LATEST" - 최신 조회
    func execute(hobbyId: Int, type: String = "ALL") async throws -> AIActivityItemsResult {
        return try await activityRepository.fetchAIActivityItems(hobbyId: hobbyId, type: type)
    }
}
