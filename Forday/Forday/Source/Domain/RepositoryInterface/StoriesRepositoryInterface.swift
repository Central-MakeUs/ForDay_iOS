//
//  StoriesRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

protocol StoriesRepositoryInterface {
    /// 소식 기록 목록 조회 (탭 정보 포함)
    func fetchStories(
        hobbyId: Int?,
        lastRecordId: Int?,
        size: Int,
        keyword: String?,
        filterType: StoryFilterType
    ) async throws -> StoriesResult?
}
