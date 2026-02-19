//
//  StoriesAPI.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

enum StoriesAPI {
    case stories       /// 소식 기록 목록 조회 (탭 정보 포함)

    var endpoint: String {
        switch self {
        case .stories:
            return "/records/stories"
        }
    }
}
