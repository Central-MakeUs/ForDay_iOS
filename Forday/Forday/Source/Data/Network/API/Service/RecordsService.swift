//
//  RecordsService.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation
import Moya

final class RecordsService {

    private let provider: MoyaProvider<RecordsTarget>

    init(provider: MoyaProvider<RecordsTarget> = NetworkProvider.createProvider()) {
        self.provider = provider
    }

    // MARK: - 활동 기록 상세 조회

    /// 활동 기록 상세 정보를 가져옵니다.
    ///
    /// - Parameter recordId: 조회할 활동 기록 ID
    /// - Returns: 활동 기록 상세 정보
    /// - Throws:
    ///   - `ACTIVITY_RECORD_NOT_FOUND` (404): 존재하지 않는 활동 기록
    ///   - `FRIEND_ONLY_ACCESS` (403): 친구 공개 글, 친구가 아닌 사용자 조회 시
    ///   - `PRIVATE_RECORD` (403): 나만보기 글, 작성자가 아닌 사용자 조회 시
    func fetchRecordDetail(recordId: Int) async throws -> DTO.ActivityRecordDetailResponse {
        return try await provider.request(.fetchRecordDetail(recordId: recordId))
    }

    // MARK: - 활동 기록 수정

    /// 활동 기록을 수정합니다.
    ///
    /// - Parameters:
    ///   - recordId: 수정할 활동 기록 ID
    ///   - request: 수정할 활동 기록 정보
    /// - Returns: 수정된 활동 기록 정보
    /// - Throws:
    ///   - `ACTIVITY_RECORD_NOT_FOUND` (404): 존재하지 않는 활동 기록
    ///   - `ACTIVITY_NOT_FOUND` (404): 존재하지 않는 활동
    ///   - `S3_IMAGE_NOT_FOUND` (404): S3에 이미지가 존재하지 않음
    func updateRecord(recordId: Int, request: DTO.UpdateRecordRequest) async throws -> DTO.UpdateRecordResponse {
        return try await provider.request(.updateRecord(recordId: recordId, request: request))
    }

    // MARK: - 활동 기록 삭제

    /// 활동 기록을 삭제합니다.
    ///
    /// - Parameter recordId: 삭제할 활동 기록 ID
    /// - Returns: 삭제 결과
    /// - Throws:
    ///   - `ACTIVITY_RECORD_NOT_FOUND` (404): 존재하지 않는 활동 기록
    func deleteRecord(recordId: Int) async throws -> DTO.DeleteRecordResponse {
        return try await provider.request(.deleteRecord(recordId: recordId))
    }

    // MARK: - 활동 기록 반응 추가

    /// 활동 기록에 반응을 추가합니다.
    ///
    /// - Parameters:
    ///   - recordId: 반응을 추가할 활동 기록 ID
    ///   - reactionType: 반응 타입 (AWESOME, GREAT, AMAZING, FIGHTING)
    /// - Returns: 반응 추가 결과
    /// - Throws:
    ///   - `ACTIVITY_RECORD_NOT_FOUND` (404): 존재하지 않는 활동 기록
    ///   - `DUPLICATE_REACTION` (400): 이미 같은 반응을 남긴 경우
    ///   - `FRIEND_ONLY_ACCESS` (403): 친구 공개 글, 친구가 아닌 사용자 조회 시
    ///   - `PRIVATE_RECORD` (403): 나만보기 글, 작성자가 아닌 사용자 조회 시
    func addReaction(recordId: Int, reactionType: ReactionType) async throws -> DTO.AddReactionResponse {
        return try await provider.request(.addReaction(recordId: recordId, reactionType: reactionType))
    }

    // MARK: - 활동 기록 반응 취소

    /// 활동 기록의 반응을 취소합니다.
    ///
    /// - Parameters:
    ///   - recordId: 반응을 취소할 활동 기록 ID
    ///   - reactionType: 취소할 반응 타입 (AWESOME, GREAT, AMAZING, FIGHTING)
    /// - Returns: 반응 취소 결과
    /// - Throws:
    ///   - `ACTIVITY_RECORD_NOT_FOUND` (404): 존재하지 않는 활동 기록
    ///   - `REACTION_NOT_FOUND` (404): 해당 리액션이 존재하지 않거나 이미 취소된 경우
    func deleteReaction(recordId: Int, reactionType: ReactionType) async throws -> DTO.DeleteReactionResponse {
        return try await provider.request(.deleteReaction(recordId: recordId, reactionType: reactionType))
    }

    // MARK: - 활동 기록 반응 사용자 목록 조회

    /// 특정 반응을 남긴 사용자 목록을 조회합니다.
    ///
    /// - Parameters:
    ///   - recordId: 활동 기록 ID
    ///   - reactionType: 조회할 반응 타입 (AWESOME, GREAT, AMAZING, FIGHTING)
    ///   - lastUserId: 무한 스크롤용 마지막 사용자 ID (첫 조회 시 nil)
    ///   - size: 조회할 사용자 수 (기본값: 10)
    /// - Returns: 반응 사용자 목록 및 페이지네이션 정보
    /// - Throws:
    ///   - `ACTIVITY_RECORD_NOT_FOUND` (404): 존재하지 않는 활동 기록
    ///   - `NOT_ACTIVITY_OWNER` (403): 활동 소유자가 아닌 경우
    func fetchReactionUsers(
        recordId: Int,
        reactionType: ReactionType,
        lastUserId: String?,
        size: Int = 10
    ) async throws -> DTO.FetchReactionUsersResponse {
        return try await provider.request(.fetchReactionUsers(
            recordId: recordId,
            reactionType: reactionType,
            lastUserId: lastUserId,
            size: size
        ))
    }

    // MARK: - 활동 기록 스크랩 추가

    /// 활동 기록을 스크랩합니다.
    ///
    /// - Parameter recordId: 스크랩할 활동 기록 ID
    /// - Returns: 스크랩 결과
    /// - Throws:
    ///   - `ACTIVITY_RECORD_NOT_FOUND` (404): 존재하지 않는 활동 기록
    ///   - `FRIEND_ONLY_ACCESS` (403): 친구 공개 글, 친구가 아닌 사용자 조회 시
    ///   - `PRIVATE_RECORD` (403): 나만보기 글, 작성자가 아닌 사용자 조회 시
    ///   - `DUPLICATE_SCRAP` (400): 이미 스크랩한 경우
    func addScrap(recordId: Int) async throws -> DTO.ScrapResponse {
        return try await provider.request(.addScrap(recordId: recordId))
    }

    // MARK: - 활동 기록 스크랩 취소

    /// 활동 기록의 스크랩을 취소합니다.
    ///
    /// - Parameter recordId: 스크랩을 취소할 활동 기록 ID
    /// - Returns: 스크랩 취소 결과
    func deleteScrap(recordId: Int) async throws -> DTO.ScrapResponse {
        return try await provider.request(.deleteScrap(recordId: recordId))
    }

    // MARK: - 활동 기록 신고

    /// 활동 기록을 신고합니다.
    ///
    /// - Parameters:
    ///   - recordId: 신고할 활동 기록 ID
    ///   - reason: 신고 사유
    /// - Returns: 신고 결과
    /// - Throws:
    ///   - `ACTIVITY_RECORD_NOT_FOUND` (404): 존재하지 않는 활동 기록
    func reportRecord(recordId: Int, reason: ReportReasonType) async throws -> DTO.ReportRecordResponse {
        let request = DTO.ReportRecordRequest(reason: reason.rawValue)
        return try await provider.request(.reportRecord(recordId: recordId, request: request))
    }
}
