//
//  HomeSettingsMenuItem.swift
//  Forday
//
//  Created by Subeen on 2/3/26.
//

import UIKit

enum HomeSettingsMenuItem: CaseIterable, DropdownMenuItem {
    case manageHobby
    case addHobby
    case generalSettings

    var title: String {
        switch self {
        case .manageHobby: return "내 취미관리"
        case .addHobby: return "취미 추가"
        case .generalSettings: return "전체설정"
        }
    }

    var textColor: UIColor { .neutral800 }
}
