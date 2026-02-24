//
//  TemplateStyle.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import UIKit

// MARK: - Template Gradient

/// 이미지 템플릿용 그라데이션 정의
enum TemplateGradient {

    /// Template smile gradient (Orange): 50% 지점부터 시작
    static let smile = AppGradient(
        colors: [
            UIColor(hex: "FFE6D1").withAlphaComponent(0),
            UIColor(hex: "F4A261")
        ],
        start: .top,
        end: .bottom,
        locations: [0.5, 1.0]
    )

    /// Template laugh gradient (Blue): 50% 지점부터 시작
    static let laugh = AppGradient(
        colors: [
            UIColor(hex: "8FB3FF").withAlphaComponent(0),
            UIColor(hex: "8FB3FF")
        ],
        start: .top,
        end: .bottom,
        locations: [0.5, 1.0]
    )

    /// Template sad gradient (Green): 50% 지점부터 시작
    static let sad = AppGradient(
        colors: [
            UIColor(hex: "A8D8A2").withAlphaComponent(0),
            UIColor(hex: "97D190")
        ],
        start: .top,
        end: .bottom,
        locations: [0.5, 1.0]
    )

    /// Template angry gradient (Yellow): 50% 지점부터 시작
    static let angry = AppGradient(
        colors: [
            UIColor(hex: "FFD56A").withAlphaComponent(0),
            UIColor(hex: "F9CC5B")
        ],
        start: .top,
        end: .bottom,
        locations: [0.5, 1.0]
    )

    /// StickerType에 따른 그라데이션 반환
    static func gradient(for stickerType: StickerType) -> AppGradient {
        switch stickerType {
        case .smile:
            return smile
        case .sad:
            return sad
        case .laugh:
            return laugh
        case .angry:
            return angry
        }
    }
}

// MARK: - Template Type

/// 템플릿 타입 정의 (추후 확장 가능)
enum TemplateType: Int, CaseIterable {
    case card = 0       // 카드형 템플릿
    case gradient = 1   // 그라데이션 템플릿

    var displayName: String {
        switch self {
        case .card:
            return "카드"
        case .gradient:
            return "그라데이션"
        }
    }
}
