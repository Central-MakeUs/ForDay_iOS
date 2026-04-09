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

    // MARK: - 활동 기록 상세 조회 (v1 - 단일)

    /// 활동 기록 상세 정보를 가져옵니다 (v1 - 페이징 정보 미포함).
    func fetchRecordDetail(recordId: Int) async throws -> DTO.ActivityRecordDetailResponse {
        return try await provider.request(.fetchRecordDetail(recordId: recordId))
    }

    // MARK: - 활동 기록 상세 조회 (v2 - 페이징)

    /// 활동 기록 상세 정보를 가져옵니다 (v2 - prevRecordId, nextRecordId 포함).
    func fetchRecordDetailV2(recordId: Int, context: ActivityDetailContext) async throws -> DTO.ActivityRecordDetailResponse {
        return try await provider.request(.fetchRecordDetailV2(recordId: recordId, context: context))
    }

    // MARK: - 활동 기록 수정

    /// 활동 기록을 수정합니다.
    func updateRecord(recordId: Int, request: DTO.UpdateRecordRequest) async throws -> DTO.UpdateRecordResponse {
        return try await provider.request(.updateRecord(recordId: recordId, request: request))
    }

    // MARK: - 활동 기록 삭제

    /// 활동 기록을 삭제합니다.
    func deleteRecord(recordId: Int) async throws -> DTO.DeleteRecordResponse {
        return try await provider.request(.deleteRecord(recordId: recordId))
    }

    // MARK: - 활동 기록 반응 추가

    /// 활동 기록에 반응을 추가합니다.
    func addReaction(recordId: Int, reactionType: ReactionType) async throws -> DTO.AddReactionResponse {
        return try await provider.request(.addReaction(recordId: recordId, reactionType: reactionType))
    }

    // MARK: - 활동 기록 반응 취소

    /// 활동 기록의 반응을 취소합니다.
    func deleteReaction(recordId: Int, reactionType: ReactionType) async throws -> DTO.DeleteReactionResponse {
        return try await provider.request(.deleteReaction(recordId: recordId, reactionType: reactionType))
    }

    // MARK: - 활동 기록 반응 사용자 목록 조회

    /// 특정 반응을 남긴 사용자 목록을 조회합니다.
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

    // MARK: - 감정 반응 요약 및 전체 탭 데이터 조회 (v2)

    /// 감정 반응 요약 및 전체 탭 데이터를 조회합니다.
    func fetchReactionSummary(
        recordId: Int,
        size: Int = 20
    ) async throws -> DTO.FetchReactionSummaryResponse {
        return try await provider.request(.fetchReactionSummary(recordId: recordId, size: size))
    }

    // MARK: - 특정 감정 반응 탭 페이지네이션 (v2)

    /// 특정 감정 반응 탭의 추가 데이터를 조회합니다.
    func fetchReactionTabData(
        recordId: Int,
        reactionType: ReactionType?,
        lastReactionId: Int,
        size: Int = 10
    ) async throws -> DTO.FetchReactionTabDataResponse {
        return try await provider.request(.fetchReactionTabData(
            recordId: recordId,
            reactionType: reactionType,
            lastReactionId: lastReactionId,
            size: size
        ))
    }

    // MARK: - 활동 기록 스크랩 추가

    /// 활동 기록을 스크랩합니다.
    func addScrap(recordId: Int) async throws -> DTO.ScrapResponse {
        return try await provider.request(.addScrap(recordId: recordId))
    }

    // MARK: - 활동 기록 스크랩 취소

    /// 활동 기록의 스크랩을 취소합니다.
    func deleteScrap(recordId: Int) async throws -> DTO.ScrapResponse {
        return try await provider.request(.deleteScrap(recordId: recordId))
    }

    // MARK: - 활동 기록 신고

    /// 활동 기록을 신고합니다.
    func reportRecord(recordId: Int, reason: ReportReasonType) async throws -> DTO.ReportRecordResponse {
        let request = DTO.ReportRecordRequest(reason: reason.rawValue)
        return try await provider.request(.reportRecord(recordId: recordId, request: request))
    }
}
