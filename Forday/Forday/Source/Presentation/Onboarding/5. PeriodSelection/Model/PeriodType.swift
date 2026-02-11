//
//  PeriodType.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//


import Foundation

enum PeriodType {
    case flexible  // 자율 모드
    case fixed    // 66일 (포데이 모드)
    
    var title: String {
        switch self {
        case .flexible:
            return "기간 미지정\n(자율모드)"
        case .fixed:
            return "66일\n(포데이 모드)"
        }
    }
    
    var subtitle: String {
        switch self {
        case .flexible:
            return "정해두지 않고, 흐름대로"
        case .fixed:
            return "생활에 자연스럽게\n스며드는 기간"
        }
    }
    
    var days: Int? {
        switch self {
        case .flexible:
            return nil
        case .fixed:
            return 66
        }
    }
}

struct PeriodModel {
    let id: String
    let type: PeriodType

    var title: String { type.title }
    var subtitle: String { type.subtitle }
}
