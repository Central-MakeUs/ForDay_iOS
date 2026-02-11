//
//  NicknameValidationResult.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import UIKit

enum NicknameValidationResult: Equatable {
    case initial           // 첫 진입 (아무것도 입력 안 함)
    case valid             // 유효한 형식 (중복확인 전)
    case empty             // 입력 후 다 지움
    case invalidCharacters // 한글, 영어 외 문자 포함
    case duplicate         // 중복된 닉네임
    case available         // 사용 가능한 닉네임 (중복확인 성공)

    var message: String? {
        switch self {
        case .initial:
            return nil
        case .valid:
            return nil
        case .empty:
            return "필수 입력 항목입니다."
        case .invalidCharacters:
            return "한글, 영어만 입력할 수 있습니다."
        case .duplicate:
            return "이미 사용중인 닉네임 입니다."
        case .available:
            return "사용 가능한 닉네임입니다."
        }
    }

    var messageColor: UIColor {
        switch self {
        case .available:
            return UIColor(hex: "4A90D9")  // 파란색
        default:
            return .secondary001           // 빨간색
        }
    }

    /// 중복확인 버튼 활성화 여부
    var isDuplicateCheckEnabled: Bool {
        switch self {
        case .valid:
            return true
        default:
            return false
        }
    }
}
