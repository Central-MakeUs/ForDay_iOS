//
//  RecordsAPI.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

enum RecordsAPI {
    case fetchRecordDetail(Int)      /// 활동 기록 상세 조회 (v1)
    case fetchRecordDetailV2(Int)    /// 활동 기록 상세 조회 (v2 - 페이징용)
    case fetchRecordDetailV3(Int)    /// 활동 기록 상세 조회 (v3 - 다중 이미지)
    case updateRecord(recordId: Int)  /// 활동 기록 수정 (v1)
    case updateRecordV2(recordId: Int)  /// 활동 기록 수정 (v2 - 다중 이미지)
    case deleteRecord(Int)  /// 활동 기록 삭제 (v1)
    case deleteRecordV2(Int)  /// 활동 기록 삭제 (v2)
    case addReaction(recordId: Int)  /// 활동 기록에 반응 추가
    case deleteReaction(recordId: Int)  /// 활동 기록 반응 삭제
    case fetchReactionUsers(recordId: Int)  /// 활동 기록에 새로 반응한 사용자 목록 조회
    case fetchReactionSummary(recordId: Int)  /// 감정 반응 요약 및 전체 탭 데이터 조회 (v2)
    case fetchReactionTabData(recordId: Int)  /// 특정 감정 반응 탭 페이지네이션 (v2)
    case addScrap(recordId: Int)  /// 활동 기록 스크랩 추가
    case deleteScrap(recordId: Int)  /// 활동 기록 스크랩 취소
    case reportRecord(recordId: Int)  /// 활동 기록 신고
    case fetchKeyboardKeywords  /// 취미별 키보드 키워드 조회

    var endpoint: String {
        switch self {
        case .fetchRecordDetail(let recordId):
            return "/records/\(recordId)"
        case .fetchRecordDetailV2(let recordId):
            return "/api/v2/records/\(recordId)"
        case .fetchRecordDetailV3(let recordId):
            return "/api/v3/records/\(recordId)"
        case .updateRecord(let recordId):
            return "/records/\(recordId)"
        case .updateRecordV2(let recordId):
            return "/api/v2/records/\(recordId)"
        case .deleteRecord(let recordId):
            return "/records/\(recordId)"
        case .deleteRecordV2(let recordId):
            return "/api/v2/records/\(recordId)"
        case .addReaction(let recordId):
            return "/records/\(recordId)/reaction"
        case .deleteReaction(let recordId):
            return "/records/\(recordId)/reaction"
        case .fetchReactionUsers(let recordId):
            return "/records/\(recordId)/reaction-users"
        case .fetchReactionSummary(let recordId):
            return "/api/v2/records/\(recordId)/reactions/summary"
        case .fetchReactionTabData(let recordId):
            return "/api/v2/records/\(recordId)/reactions"
        case .addScrap(let recordId):
            return "/records/\(recordId)/scrap"
        case .deleteScrap(let recordId):
            return "/records/\(recordId)/scrap"
        case .reportRecord(let recordId):
            return "/records/\(recordId)/report"
        case .fetchKeyboardKeywords:
            return "/api/v2/records/keyboard-keywords"
        }
    }
}
