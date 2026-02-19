//
//  StoriesTarget.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation
import Moya
import Alamofire

enum StoriesTarget {
    case fetchStories(hobbyId: Int?, lastRecordId: Int?, size: Int, keyword: String?, filterType: StoryFilterType)  /// 소식 목록 조회 (GET /records/stories) - 탭 정보 포함
}

extension StoriesTarget: BaseTargetType {

    var path: String {
        switch self {
        case .fetchStories:
            return StoriesAPI.stories.endpoint
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchStories:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .fetchStories(let hobbyId, let lastRecordId, let size, let keyword, let filterType):
            var parameters: [String: Any] = [
                "size": size,
                "storyFilterType": filterType.rawValue
            ]

            if let hobbyId = hobbyId {
                parameters["hobbyId"] = hobbyId
            }
            if let lastRecordId = lastRecordId {
                parameters["lastRecordId"] = lastRecordId
            }
            if let keyword = keyword {
                parameters["keyword"] = keyword
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
}
