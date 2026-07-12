//
//  UpdateActivityRecordUseCase.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

final class UpdateActivityRecordUseCase {

    private let recordsService: RecordsService

    init(recordsService: RecordsService = RecordsService()) {
        self.recordsService = recordsService
    }

    /// V1 API 호환용 (deprecated) - 단일 이미지 지원
    @available(*, deprecated, message: "Use execute with images array instead")
    func execute(
        recordId: Int,
        activityId: Int,
        sticker: String,
        memo: String?,
        imageUrl: String?,
        visibility: Privacy
    ) async throws -> UpdateRecordResult {
        // 단일 이미지를 배열로 변환
        var images: [RecordImageInput] = []
        if let url = imageUrl {
            images.append(RecordImageInput(
                imageUrl: url,
                imageOrder: 1,
                imageWidth: 0,  // V1에서는 크기 정보 없음
                imageHeight: 0
            ))
        }

        return try await execute(
            recordId: recordId,
            activityId: activityId,
            sticker: sticker,
            memo: memo,
            images: images,
            visibility: visibility
        )
    }

    /// 활동 기록을 수정합니다 (V2 API - 다중 이미지 지원).
    ///
    /// - Parameters:
    ///   - recordId: 수정할 활동 기록 ID
    ///   - activityId: 변경할 활동 ID (nil이면 기존 활동 유지)
    ///   - sticker: 스티커 파일명 (예: "smile.jpg")
    ///   - memo: 메모 (옵션)
    ///   - images: 이미지 정보 배열 (최대 5장)
    ///   - visibility: 공개 범위 (PUBLIC, FRIEND, PRIVATE)
    /// - Returns: 수정된 활동 기록 정보
    /// - Throws: API 에러
    func execute(
        recordId: Int,
        activityId: Int?,
        sticker: String,
        memo: String?,
        images: [RecordImageInput],
        visibility: Privacy
    ) async throws -> UpdateRecordResult {
        // Convert RecordImageInput to DTO.ImageInput
        let imageInputs = images.map { image in
            DTO.ImageInput(
                imageUrl: image.imageUrl,
                imageOrder: image.imageOrder,
                imageWidth: image.imageWidth,
                imageHeight: image.imageHeight
            )
        }

        let request = DTO.UpdateRecordV2Request(
            activityId: activityId,
            sticker: sticker,
            memo: memo,
            images: imageInputs,
            visibility: visibility.rawValue
        )

        let response = try await recordsService.updateRecordV2(recordId: recordId, request: request)
        return response.toDomain()
    }
}
