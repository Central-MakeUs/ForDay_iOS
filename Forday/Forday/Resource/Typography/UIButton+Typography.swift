//
//  UIButton+Typography.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//

import UIKit

extension UIButton {
    /// Configuration을 사용하는 UIButton에 Typography 스타일 적용
    /// - Parameter style: 적용할 TypographyStyle
    func applyTypography(_ style: TypographyStyle) {
        guard var config = self.configuration else { return }
        
        let title = config.title ?? ""
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer(style.attributes)
        )
        
        self.configuration = config
    }
    
    /// 텍스트와 함께 Typography 스타일을 적용
    /// - Parameters:
    ///   - title: 버튼에 표시할 텍스트
    ///   - style: 적용할 TypographyStyle
    func setTitleWithTypography(_ title: String, style: TypographyStyle) {
        guard var config = self.configuration else {
            // Configuration이 없으면 기본 생성
            var newConfig = UIButton.Configuration.plain()
            newConfig.attributedTitle = AttributedString(
                title,
                attributes: AttributeContainer(style.attributes)
            )
            self.configuration = newConfig
            return
        }
        
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer(style.attributes)
        )
        self.configuration = config
    }
}
