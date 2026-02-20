//
//  UsersAPI.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

enum UsersAPI {
    case nicknameAvailability   /// 닉네임 중복 확인
    case settingNickname        /// 닉네임 설정
    case info                   /// 사용자 정보 조회
    case profileImageUpload     /// 사용자 프로필 이미지 설정
    case hobbiesInProgress      /// 사용자 취미 진행 상단탭 조회
    case feeds                  /// 사용자 피드 목록 조회
    case hobbyCards             /// 사용자 취미 카드 리스트 조회
    case scraps                 /// 사용자 스크랩 목록 조회
    case blockUser(userId: String)  /// 사용자 차단


    var endpoint: String {
        switch self {
        case .nicknameAvailability:
            return "/users/nickname/availability"
        case .settingNickname:
            return "/users/nickname"
        case .info:
            return "/users/info"
        case .profileImageUpload:
            return "/users/profile-image"
        case .hobbiesInProgress:
            return "/users/hobbies/in-progress"
        case .feeds:
            return "/users/feeds"
        case .hobbyCards:
            return "/users/hobby-cards"
        case .scraps:
            return "/users/scraps"
        case .blockUser(let userId):
            return "/users/\(userId)/block"
        }
    }
}
