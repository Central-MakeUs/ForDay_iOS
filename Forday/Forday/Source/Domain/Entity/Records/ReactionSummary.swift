//
//  ReactionSummary.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import Foundation

/// 감정 반응 요약 (각 타입별 카운트)
struct ReactionSummary {
    let totalCount: Int
    let awesome: Int
    let great: Int
    let amazing: Int
    let fighting: Int

    /// 특정 리액션 타입의 카운트 반환
    func count(for type: ReactionType) -> Int {
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
extension ReactionSummary {
    static var preview: ReactionSummary {
        ReactionSummary(
            totalCount: 12,
            awesome: 3,
            great: 3,
            amazing: 3,
            fighting: 3
        )
    }

    static var empty: ReactionSummary {
        ReactionSummary(
            totalCount: 0,
            awesome: 0,
            great: 0,
            amazing: 0,
            fighting: 0
        )
    }
}
#endif
