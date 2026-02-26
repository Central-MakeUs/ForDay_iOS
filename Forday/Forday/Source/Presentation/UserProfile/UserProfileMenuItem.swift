//
//  UserProfileMenuItem.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import UIKit

enum UserProfileMenuItem: DropdownMenuItem {
    case report
    case block

    var title: String {
        switch self {
        case .report:
            return "신고하기"
        case .block:
            return "차단하기"
        }
    }

    var textColor: UIColor {
        switch self {
        case .report, .block:
            return .neutral800
        }
    }

    var fontWeight: TypographyStyle {
        return .body16
    }

    static var menuItems: [UserProfileMenuItem] {
        [.report, .block]
    }
}
