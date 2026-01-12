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
    func setTextWithTypography(_ text: String, style: TypographyStyle) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(
            style.attributes,
            range: NSRange(location: 0, length: text.utf16.count)
        )
        self.attributedText = attributedString
    }
}
