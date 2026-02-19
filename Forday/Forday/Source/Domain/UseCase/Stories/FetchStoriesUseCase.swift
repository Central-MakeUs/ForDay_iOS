//
//  FetchStoriesUseCase.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

final class FetchStoriesUseCase {

    private let repository: StoriesRepositoryInterface

    init(repository: StoriesRepositoryInterface = StoriesRepository()) {
        self.repository = repository
    }

    func execute(
        hobbyId: Int? = nil,
        lastRecordId: Int? = nil,
        size: Int = 20,
        keyword: String? = nil,
        filterType: StoryFilterType = .all
    ) async throws -> StoriesResult? {
        return try await repository.fetchStories(
            hobbyId: hobbyId,
            lastRecordId: lastRecordId,
            size: size,
            keyword: keyword,
            filterType: filterType
        )
    }
}
