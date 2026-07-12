//
//  FetchKeyboardKeywordsUseCase.swift
//  Forday
//
//  Created by Subeen on 7/8/26.
//

import Foundation

/// 취미별 키보드 키워드를 조회하는 UseCase
/// - Note: 기록 작성 시 메모 입력 추천 문장으로 사용
final class FetchKeyboardKeywordsUseCase {

    private let repository: ActivityRepositoryInterface

    init(repository: ActivityRepositoryInterface = ActivityRepository()) {
        self.repository = repository
    }

    /// 취미 정보 ID에 해당하는 키보드 키워드 목록을 조회합니다.
    /// - Parameter hobbyInfoId: 취미 정보 ID
    /// - Returns: 키보드 키워드 배열
    func execute(hobbyInfoId: Int) async throws -> [KeyboardKeyword] {
        return try await repository.fetchKeyboardKeywords(hobbyInfoId: hobbyInfoId)
    }
}
