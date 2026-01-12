//
//  TypographyStyle.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


//
//  TypographyStyle.swift
//  Forday
//
//  Created by 숩 on 1/12/26.
//

import UIKit

struct TypographyStyle {
    let font: UIFont
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
    
    /// NSAttributedString에 적용할 attributes 반환
    var attributes: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        // 폰트의 기본 lineHeight와 디자인 lineHeight의 차이만큼 baselineOffset 조정
        let baselineOffset = (lineHeight - font.lineHeight) / 4
        
        return [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: baselineOffset,
            .kern: letterSpacing
        ]
    }
}

enum FontName: String {
    case pretendardBold = "Pretendard-Bold"
    case pretendardSemiBold = "Pretendard-SemiBold"
    case pretendardRegular = "Pretendard-Regular"
    case pretendardMedium = "Pretendard-Medium"
}

extension TypographyStyle {
    
    // Header
    
    /// header 24 - Pretendard SemiBold 24px 120%
    static let header24 = TypographyStyle(
        font: UIFont(name: FontName.pretendardSemiBold.rawValue, size: 24) ?? .systemFont(ofSize: 24, weight: .bold),
        lineHeight: 24 * 1.2,
        letterSpacing: 0
    )
    
    /// header 22 -  Pretendard Bold 22px 26
    static let header22 = TypographyStyle(
        font: UIFont(name: FontName.pretendardBold.rawValue, size: 22) ?? .systemFont(ofSize: 22, weight: .bold),
        lineHeight: 26,
        letterSpacing: 0
    )
    
    /// header 20px 120%
    static let header20 = TypographyStyle(
        font: UIFont(name: FontName.pretendardBold.rawValue, size: 20) ?? .systemFont(ofSize: 20, weight: .bold),
        lineHeight: 20 * 1.2,
        letterSpacing: 0
    )
    
    /// header 18px 120%
    static let header18 = TypographyStyle(
        font: UIFont(name: FontName.pretendardBold.rawValue, size: 18) ?? .systemFont(ofSize: 18, weight: .bold),
        lineHeight: 18 * 1.2,
        letterSpacing: 0
    )
    
    /// header 16px 120%
    static let header16 = TypographyStyle(
        font: UIFont(name: FontName.pretendardBold.rawValue, size: 16) ?? .systemFont(ofSize: 16, weight: .bold),
        lineHeight: 16 * 1.2,
        letterSpacing: 0
    )
    
    /// header 14px 120%
    static let header14 = TypographyStyle(
        font: UIFont(name: FontName.pretendardBold.rawValue, size: 14) ?? .systemFont(ofSize: 14, weight: .bold),
        lineHeight: 14 * 1.2,
        letterSpacing: 0
    )
    
    // body
    
    /// body 16px 120%
    static let body16 = TypographyStyle(
        font: UIFont(name: FontName.pretendardMedium.rawValue, size: 16) ?? .systemFont(ofSize: 16, weight: .medium),
        lineHeight: 16 * 1.4,
        letterSpacing: 0
    )
    
    /// body 14px 120%
    static let body14 = TypographyStyle(
        font: UIFont(name: FontName.pretendardMedium.rawValue, size: 14) ?? .systemFont(ofSize: 14, weight: .medium),
        lineHeight: 14 * 1.4,
        letterSpacing: 0
    )
    
    /// body 12px 140%
    static let body12 = TypographyStyle(
        font: UIFont(name: FontName.pretendardMedium.rawValue, size: 12) ?? .systemFont(ofSize: 12, weight: .medium),
        lineHeight: 12 * 1.4,
        letterSpacing: 0
    )
    
    // Label
    
    /// label 16px 140%
    static let label16 = TypographyStyle(
        font: UIFont(name: FontName.pretendardRegular.rawValue, size: 16) ?? .systemFont(ofSize: 16, weight: .regular),
        lineHeight: 16 * 1.4,
        letterSpacing: 0
    )
    
    /// label 14px 140%
    static let label14 = TypographyStyle(
        font: UIFont(name: FontName.pretendardRegular.rawValue, size: 14) ?? .systemFont(ofSize: 14, weight: .regular),
        lineHeight: 14 * 1.4,
        letterSpacing: 0
    )
    
    /// label 12px 140%
    static let label12 = TypographyStyle(
        font: UIFont(name: FontName.pretendardRegular.rawValue, size: 12) ?? .systemFont(ofSize: 12, weight: .regular),
        lineHeight: 12 * 1.4,
        letterSpacing: 0
    )
    
    /// label 10px 140%
    static let label10 = TypographyStyle(
        font: UIFont(name: FontName.pretendardRegular.rawValue, size: 10) ?? .systemFont(ofSize: 10, weight: .regular),
        lineHeight: 10 * 1.4,
        letterSpacing: 0
    )
}
