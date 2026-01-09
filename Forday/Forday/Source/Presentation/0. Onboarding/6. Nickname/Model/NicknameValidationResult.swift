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
    case tooLong
    case duplicate
    
    var message: String? {
        switch self {
        case .valid:
            return nil
        case .empty:
            return "닉네임을 입력해주세요."
        case .invalidCharacters:
            return "한글, 영어만 입력할 수 있습니다."
        case .tooLong:
            return "닉네임은 최대 10자까지 입력 가능합니다."
        case .duplicate:
            return "이미 사용 중인 닉네임입니다."
        }
    }
}