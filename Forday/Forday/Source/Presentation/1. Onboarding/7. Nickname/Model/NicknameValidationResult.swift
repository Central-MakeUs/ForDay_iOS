//
//  NicknameValidationResult.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

enum NicknameValidationResult {
    case valid
    case empty
    case invalidCharacters
    case duplicate
    
    var message: String? {
        switch self {
        case .valid:
            return nil
        case .empty:
            return "필수 입력 항목입니다."
        case .invalidCharacters:
            return "한글, 영어, 숫자만 사용할 수 있습니다."
        case .duplicate:
            return "이미 사용 중인 닉네임입니다."
        }
    }
}
