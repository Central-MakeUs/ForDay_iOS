//
//  MySettingsMenuItem.swift
//  Forday
//
//  Created by Subeen on 2/3/26.
//

import UIKit

enum MySettingsMenuItem: DropdownMenuItem {
    case profileSettings
    case hobbyPhotoManagement
    case generalSettings

    var title: String {
        switch self {
        case .profileSettings:
            return "내 프로필 설정"
        case .hobbyPhotoManagement:
            return "취미 대표사진 관리"
        case .generalSettings:
            return "전체설정"
        }
    }

    var textColor: UIColor {
        switch self {
        case .generalSettings:
            return .action001
        default:
            return .neutral800
        }
    }

    var fontWeight: TypographyStyle {
        switch self {
        case .generalSettings:
            return .header16
        default:
            return .body16
        }
    }

    // MARK: - User Type-Based Menu Items

    /// 소셜 로그인 유저용 메뉴 아이템
    static var socialLoginMenuItems: [MySettingsMenuItem] {
        [.profileSettings, .hobbyPhotoManagement, .generalSettings]
    }
}

// MARK: - Guest Settings Menu Item

/// 게스트 유저용 설정 메뉴 아이템
struct GuestSettingsMenuItem: DropdownMenuItem {
    let title: String
    let textColor: UIColor
    let fontWeight: TypographyStyle

    /// 전체 설정
    static let generalSettings = GuestSettingsMenuItem(
        title: "전체설정",
        textColor: .neutral800,
        fontWeight: .body16
    )

    /// 게스트 유저용 메뉴 아이템
    static var menuItems: [GuestSettingsMenuItem] {
        [.generalSettings]
    }
}
