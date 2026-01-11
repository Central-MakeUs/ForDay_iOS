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
    
    var displayText: String {
        switch self {
        case .flexible:
            return "자율 모드"
        case .fixed:
            return "66일"
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
    let title: String
    let subtitle: String
    let type: PeriodType
}
