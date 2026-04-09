//
//  ReactionSummaryResponse.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import Foundation

/// 감정 반응 목록 최초 조회 응답
struct ReactionSummaryResponse {
    let recordId: Int
    let reactionSummary: ReactionSummary
    let tabs: ReactionTabs
}

/// 전체 탭 데이터
struct ReactionTabs {
    let all: ReactionTabData
    let awesome: ReactionTabData
    let great: ReactionTabData
    let amazing: ReactionTabData
    let fighting: ReactionTabData

    /// 특정 리액션 타입 또는 전체의 탭 데이터 반환
    func data(for type: ReactionType?) -> ReactionTabData {
        guard let type = type else {
            return all
        }

        switch type {
        case .awesome: return awesome
        case .great: return great
        case .amazing: return amazing
        case .fighting: return fighting
        }
    }
}

// MARK: - Preview

#if DEBUG
extension ReactionSummaryResponse {
    static var preview: ReactionSummaryResponse {
        ReactionSummaryResponse(
            recordId: 141,
            reactionSummary: .preview,
            tabs: ReactionTabs(
                all: .preview,
                awesome: .preview,
                great: .preview,
                amazing: .preview,
                fighting: .preview
            )
        )
    }
}
#endif
