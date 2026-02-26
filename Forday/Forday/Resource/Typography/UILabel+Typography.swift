//
//  UILabel+Typography.swift
//  Forday
//
//  Created by 숩 on 1/12/26.
//

import UIKit

extension UILabel {
    /// Typography 스타일을 UILabel에 적용
    /// - Parameter style: 적용할 TypographyStyle
    func applyTypography(_ style: TypographyStyle) {
        let text = self.text ?? ""
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(
            style.attributes,
            range: NSRange(location: 0, length: text.utf16.count)
        )
        self.attributedText = attributedString
    }
    
    /// 텍스트와 함께 Typography 스타일을 적용
    /// - Parameters:
    ///   - text: 표시할 텍스트
    ///   - style: 적용할 TypographyStyle
    ///   - alignment: 텍스트 정렬 (기본값: .natural)
    func setTextWithTypography(_ text: String, style: TypographyStyle, alignment: NSTextAlignment = .natural) {
        let attributedString = NSMutableAttributedString(string: text)
        var attributes = style.attributes

        // alignment가 지정된 경우 paragraphStyle에 적용
        if let paragraphStyle = attributes[.paragraphStyle] as? NSMutableParagraphStyle {
            paragraphStyle.alignment = alignment
        } else {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = alignment
            attributes[.paragraphStyle] = paragraphStyle
        }

        attributedString.addAttributes(
            attributes,
            range: NSRange(location: 0, length: text.utf16.count)
        )
        self.attributedText = attributedString
    }
}
