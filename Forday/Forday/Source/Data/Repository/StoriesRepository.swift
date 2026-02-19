//
//  StoriesRepository.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

final class StoriesRepository: StoriesRepositoryInterface {

    private let storiesService: StoriesService

    init(storiesService: StoriesService = StoriesService()) {
        self.storiesService = storiesService
    }

    // MARK: - Fetch Stories

    func fetchStories(
        hobbyId: Int?,
        lastRecordId: Int?,
        size: Int,
        keyword: String?,
        filterType: StoryFilterType
    ) async throws -> StoriesResult? {
        let response = try await storiesService.fetchStories(
            hobbyId: hobbyId,
            lastRecordId: lastRecordId,
            size: size,
            keyword: keyword,
            filterType: filterType
        )
        return response.toDomain()
    }
}
