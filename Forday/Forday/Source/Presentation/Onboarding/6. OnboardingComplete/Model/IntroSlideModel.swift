//
//  IntroSlideModel.swift
//  Forday
//
//  Created by Subeen on 2/6/26.
//


import UIKit

enum IntroCharacter: CaseIterable {
    case smile
    case laugh
    case sad
    case angry

    var image: UIImage {
        switch self {
        case .smile: return .My.smile
        case .laugh: return .My.laugh
        case .sad: return .My.sad
        case .angry: return .My.angry
        }
    }

    /// 그라디언트 시작 색상 (0.02 알파)
    var gradientStartColor: UIColor {
        switch self {
        case .smile:
            return UIColor(hex: "EE9449").withAlphaComponent(0.1)
        case .laugh:
            return UIColor(hex: "4F49EE").withAlphaComponent(0.1)
        case .sad:
            return UIColor(hex: "49EE85").withAlphaComponent(0.1)
        case .angry:
            return UIColor(hex: "EEE049").withAlphaComponent(0.1)
        }
    }
    
    var gradientMediumColor: UIColor {
        switch self {
        case .smile:
            return UIColor(hex: "EE9449").withAlphaComponent(0.6)
        case .laugh:
            return UIColor(hex: "4F49EE").withAlphaComponent(0.6)
        case .sad:
            return UIColor(hex: "49EE85").withAlphaComponent(0.6)
        case .angry:
            return UIColor(hex: "EEE049").withAlphaComponent(0.6)
        }
    }

    /// 그라디언트 끝 색상 (0.12 알파)
    var gradientEndColor: UIColor {
        switch self {
        case .smile:
            return UIColor(hex: "EE9449").withAlphaComponent(0.1)
        case .laugh:
            return UIColor(hex: "4F49EE").withAlphaComponent(0.1)
        case .sad:
            return UIColor(hex: "49EE85").withAlphaComponent(0.1)
        case .angry:
            return UIColor(hex: "EEE049").withAlphaComponent(0.1)
        }
    }

    /// 테두리 색상 (0.2 알파)
    var borderColor: UIColor {
        switch self {
        case .smile:
            return UIColor(hex: "EE9449").withAlphaComponent(0.2)
        case .laugh:
            return UIColor(hex: "4F49EE").withAlphaComponent(0.2)
        case .sad:
            return UIColor(hex: "49EE85").withAlphaComponent(0.2)
        case .angry:
            return UIColor(hex: "EEE049").withAlphaComponent(0.2)
        }
    }
}
