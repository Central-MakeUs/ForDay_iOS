//
//  UsersTarget.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation
import Moya
import Alamofire

enum UsersTarget {
    case nicknameAvailability(nickname: String)
    case setNickname(request: DTO.SetNicknameRequest)
    case feeds(hobbyIds: [Int], lastRecordId: Int?, feedSize: Int, userId: String?)
    case info(userId: String?)                   /// 사용자 정보 조회 (userId가 nil이면 본인)
    case profileImageUpload(profileImageUrl: String?)     /// 사용자 프로필 이미지 설정
    case hobbiesInProgress(userId: String?)      /// 사용자 취미 진행 상단탭 조회
    case hobbyCards(lastHobbyCardId: Int?, size: Int, userId: String?)    /// 사용자 취미 카드 리스트 조회
    case scraps(lastRecordId: Int?, feedSize: Int, userId: String?)       /// 사용자 스크랩 목록 조회
}

extension UsersTarget: BaseTargetType {
    
    var path: String {
        switch self {
        case .nicknameAvailability:
            return UsersAPI.nicknameAvailability.endpoint
        case .setNickname:
            return UsersAPI.settingNickname.endpoint
        case .feeds:
            return UsersAPI.feeds.endpoint
        case .info:
            return UsersAPI.info.endpoint
        case .profileImageUpload:
            return UsersAPI.profileImageUpload.endpoint
        case .hobbiesInProgress:
            return UsersAPI.hobbiesInProgress.endpoint
        case .hobbyCards:
            return UsersAPI.hobbyCards.endpoint
        case .scraps:
            return UsersAPI.scraps.endpoint
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .nicknameAvailability:
            return .get
        case .setNickname:
            return .patch
        case .feeds:
            return .get
        case .info:
            return .get
        case .profileImageUpload:
            return .patch
        case .hobbiesInProgress:
            return .get
        case .hobbyCards:
            return .get
        case .scraps:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .nicknameAvailability(let nickname):
            let parameters = ["nickname": nickname]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

        case .setNickname(let request):
            return .requestJSONEncodable(request)

        case .feeds(let hobbyIds, let lastRecordId, let feedSize, let userId):
            var parameters: [String: Any] = ["feedSize": feedSize]

            // hobbyIds 배열을 단일 키로 반복 전달 (hobbyId=116&hobbyId=117)
            // 빈 배열이면 hobbyId 파라미터를 아예 보내지 않음 (전체 조회)
            if !hobbyIds.isEmpty {
                parameters["hobbyId"] = hobbyIds  // 단수형 "hobbyId"로 변경
            }

            if let lastRecordId = lastRecordId {
                parameters["lastRecordId"] = lastRecordId
            }

            // userId가 있으면 해당 사용자의 피드 조회, 없으면 본인 피드 조회
            if let userId = userId {
                parameters["userId"] = userId
            }

            // ArrayEncoding.noBrackets로 hobbyId=116&hobbyId=117 형식 생성
            return .requestParameters(parameters: parameters, encoding: URLEncoding(arrayEncoding: .noBrackets))

        case .info(let userId):
            if let userId = userId {
                return .requestParameters(parameters: ["userId": userId], encoding: URLEncoding.default)
            }
            return .requestPlain

        case .profileImageUpload(let profileImageUrl):
            let parameters: [String: Any] = ["profileImageUrl": profileImageUrl as Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case .hobbiesInProgress(let userId):
            if let userId = userId {
                return .requestParameters(parameters: ["userId": userId], encoding: URLEncoding.default)
            }
            return .requestPlain

        case .hobbyCards(let lastHobbyCardId, let size, let userId):
            var parameters: [String: Any] = ["size": size]

            if let lastHobbyCardId = lastHobbyCardId {
                parameters["lastHobbyCardId"] = lastHobbyCardId
            }

            if let userId = userId {
                parameters["userId"] = userId
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

        case .scraps(let lastRecordId, let feedSize, let userId):
            var parameters: [String: Any] = ["feedSize": feedSize]

            if let lastRecordId = lastRecordId {
                parameters["lastRecordId"] = lastRecordId
            }

            if let userId = userId {
                parameters["userId"] = userId
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
}
