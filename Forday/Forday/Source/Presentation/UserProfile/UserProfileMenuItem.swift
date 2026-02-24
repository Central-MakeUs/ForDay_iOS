//
//  UserProfileMenuItem.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import UIKit

enum UserProfileMenuItem: DropdownMenuItem {
    case block
    case report

    var title: String {
        switch self {
        case .block:
            return "차단하기"
        case .report:
            return "신고하기"
        }
    }

    var textColor: UIColor {
        switch self {
        case .block:
            return .neutral800
        case .report:
            return .neutral800
        }
    }

    var fontWeight: TypographyStyle {
        return .body16
    }

    static var menuItems: [UserProfileMenuItem] {
        [.block, .report]
    }
}
