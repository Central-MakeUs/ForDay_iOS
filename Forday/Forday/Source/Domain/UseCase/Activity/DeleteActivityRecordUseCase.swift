//
//  DeleteActivityRecordUseCase.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

final class DeleteActivityRecordUseCase {

    private let recordsService: RecordsService

    init(recordsService: RecordsService = RecordsService()) {
        self.recordsService = recordsService
    }

    /// 활동 기록을 삭제합니다 (V2 API).
    ///
    /// - Note: 오늘 기록은 완전 삭제(하드 삭제), 이전 기록은 소프트 삭제됩니다.
    ///         첨부 이미지는 모두 S3에서 삭제됩니다.
    /// - Parameter recordId: 삭제할 활동 기록 ID
    /// - Returns: 삭제 결과 (삭제된 이미지 URL 목록 포함)
    /// - Throws: API 에러
    func execute(recordId: Int) async throws -> DeleteRecordResult {
        let response = try await recordsService.deleteRecordV2(recordId: recordId)
        return response.toDomain()
    }
}
