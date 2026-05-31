//
//  HomeSettingsMenuItem.swift
//  Forday
//
//  Created by Subeen on 2/3/26.
//

import UIKit

enum HomeSettingsMenuItem: CaseIterable, DropdownMenuItem {
    case manageHobby
    case generalSettings

    var title: String {
        switch self {
        case .manageHobby: return "내 취미 관리"
        case .generalSettings: return "전체설정"
        }
    }

    var textColor: UIColor { .neutral800 }
}
