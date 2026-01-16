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
    
    case fetchActivityList(Int)     /// 활동 리스트 조회
    case createActivities(Int)      /// 취미 활동 추가하기
    case updateActivity(Int)        /// 활동 수정하기
    case deleteActivity(Int)        /// 활동 삭제하기
    
    var endpoint: String {
        switch self {
        case .createHobby:
            return "/hobbies/create"
            
        case .fetchOthersActivities:
            return "/hobbies/activities/others/v1"
            
        case .fetchAIRecommendations:
            return "/hobbies/activities/ai/recommend"
            
        case .fetchActivityList(let hobbyId):
            return "/hobbies/\(hobbyId)/activities/list"
            
        case .createActivities(let hobbyId):
            return "/hobbies/\(hobbyId)/activities"
        
        case .updateActivity(let activityId):
            return "/activities/\(activityId)"
            
        case .deleteActivity(let activityId):
            return "/activities/\(activityId)"

        }
    }
}
