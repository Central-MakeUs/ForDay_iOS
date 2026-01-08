//
//  UsersAPI.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

enum UsersAPI {
    case nicknameAvailability   /// 닉네임 중복 확인
    case settingNickname        /// 닉네임 설정
    
    var endpoint: String {
        switch self {
        case .nicknameAvailability:
            return "/users/nickname/availability"
        case .settingNickname:
            return "users/nickname"
        }
    }
}
