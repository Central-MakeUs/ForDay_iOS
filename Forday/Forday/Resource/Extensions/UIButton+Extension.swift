//
//  UIButton+Extension.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//

import UIKit

extension UIButton {
    func applyTypography(_ style: TypographyStyle, for state: UIControl.State = .normal) {
        guard var config = self.configuration else { return }
        
        let title = config.title ?? ""
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer(style.attributes)
        )
        
        self.configuration = config
    }
}
