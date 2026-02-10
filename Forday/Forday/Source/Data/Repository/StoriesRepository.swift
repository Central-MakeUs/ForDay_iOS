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

    // MARK: - Fetch Stories Tabs

    func fetchStoriesTabs() async throws -> [StoriesTab] {
        let response = try await storiesService.fetchStoriesTabs()
        return response.toDomain()
    }

    // MARK: - Fetch Stories

    func fetchStories(
        hobbyId: Int?,
        lastRecordId: Int?,
        size: Int,
        keyword: String?
    ) async throws -> StoriesResult? {
        let response = try await storiesService.fetchStories(
            hobbyId: hobbyId,
            lastRecordId: lastRecordId,
            size: size,
            keyword: keyword
        )
        return response.toDomain()
    }
}

