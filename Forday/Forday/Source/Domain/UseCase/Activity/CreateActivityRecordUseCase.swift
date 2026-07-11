//
//  CreateActivityRecordUseCase.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

final class CreateActivityRecordUseCase {

    private let repository: ActivityRepositoryInterface

    init(repository: ActivityRepositoryInterface = ActivityRepository()) {
        self.repository = repository
    }

    /// V1 API (deprecated)
    @available(*, deprecated, message: "Use executeV2 instead")
    func execute(
        activityId: Int,
        sticker: String,
        memo: String?,
        imageUrl: String?,
        visibility: Privacy
    ) async throws -> ActivityRecord {
        return try await repository.createActivityRecord(
            activityId: activityId,
            sticker: sticker,
            memo: memo,
            imageUrl: imageUrl,
            visibility: visibility
        )
    }

    /// V2 API - 다중 이미지 지원, 새 활동 생성 지원
    /// - Parameters:
    ///   - hobbyId: 취미 ID
    ///   - activityId: 기존 활동 ID (activityContent와 둘 중 하나만 입력)
    ///   - activityContent: 새 활동명 (activityId와 둘 중 하나만 입력)
    ///   - sticker: 스티커 타입
    ///   - images: 이미지 배열 (최대 5장)
    ///   - visibility: 공개 범위
    ///   - memo: 메모
    ///   - activityContentValid: 새 활동명 유효성 검사 통과 여부
    func executeV2(
        hobbyId: Int,
        activityId: Int?,
        activityContent: String?,
        sticker: String,
        images: [RecordImageInput],
        visibility: Privacy,
        memo: String?,
        activityContentValid: Bool = true
    ) async throws -> ActivityRecordV2 {
        return try await repository.createActivityRecordV2(
            hobbyId: hobbyId,
            activityId: activityId,
            activityContent: activityContent,
            sticker: sticker,
            images: images,
            visibility: visibility,
            memo: memo,
            activityContentValid: activityContentValid
        )
    }
}
