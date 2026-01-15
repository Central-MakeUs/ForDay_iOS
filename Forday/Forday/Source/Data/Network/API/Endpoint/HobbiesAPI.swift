//
//  HobbiesAPI.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation

enum HobbiesAPI {
    case createHobby                /// 취미 생성
    case fetchOthersActivities      /// [Version1] 다른 포비들의  활동 조회 (AI 기반)
    case fetchAIRecommendations     /// AI 취미 활동 추천
    
    var endpoint: String {
        switch self {
        case .createHobby:
            return "/hobbies/create"
            
        case .fetchOthersActivities:
            return "/hobbies/activities/others/v1"
            
        case .fetchAIRecommendations:
            return "/hobbies/activities/ai/recommend"
        }
    }
}
