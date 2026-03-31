//
//  ActivityDetailContext.swift
//  Forday
//
//  Created by Subeen on 3/31/26.
//

import Foundation

/// 활동 기록 상세 조회 시 필요한 컨텍스트 정보
/// 목록에서 상세로 진입 시 필터/검색 상태를 유지하기 위해 사용
struct ActivityDetailContext {
    let contextType: ContextType
    let userId: String?
    let keyword: String?
    let hobbyIds: [Int]?

    enum ContextType: String {
        case storyAll = "STORY_ALL"          // 소식 전체 조회
        case storyHobby = "STORY_HOBBY"      // 소식 취미별 조회
        case userFeed = "USER_FEED"          // 유저 피드 조회
        case userScrap = "USER_SCRAP"        // 유저 스크랩 목록 조회
    }

    /// API 쿼리 파라미터로 변환
    func toQueryParameters() -> [String: Any] {
        var parameters: [String: Any] = [
            "context": contextType.rawValue
        ]

        if let userId = userId {
            parameters["userId"] = userId
        }

        if let keyword = keyword, !keyword.isEmpty {
            parameters["keyword"] = keyword
        }

        if let hobbyIds = hobbyIds, !hobbyIds.isEmpty {
            parameters["hobbyIds"] = hobbyIds.map { String($0) }.joined(separator: ",")
        }

        return parameters
    }
}
