//
//  DeleteRecordResponse.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

extension DTO {
    /// 활동 기록 삭제 V1 Response
    struct DeleteRecordResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: DeleteRecordData
    }

    struct DeleteRecordData: Codable {
        let message: String
        let recordId: Int
    }

    /// 활동 기록 삭제 V2 Response
    struct DeleteRecordV2Response: BaseResponse {
        let status: Int
        let success: Bool
        let data: DeleteRecordV2Data
    }

    struct DeleteRecordV2Data: Codable {
        let message: String
        let recordId: Int
        let deleteImageUrls: [String]?
    }
}

extension DTO.DeleteRecordResponse {
    func toDomain() -> DeleteRecordResult {
        return DeleteRecordResult(
            message: data.message,
            recordId: data.recordId,
            deleteImageUrls: nil
        )
    }
}

extension DTO.DeleteRecordV2Response {
    func toDomain() -> DeleteRecordResult {
        return DeleteRecordResult(
            message: data.message,
            recordId: data.recordId,
            deleteImageUrls: data.deleteImageUrls
        )
    }
}
