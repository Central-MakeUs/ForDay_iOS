//
//  HobbiesTarget.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation
import Moya
import Alamofire

enum HobbiesTarget {
    case createHobby(request: DTO.CreateHobbyRequest)
    case fetchAIRecommendations(hobbyId: Int)
    case fetchActivityList(hobbyId: Int)
    case createActivities(hobbyId: Int, request: DTO.CreateActivitiesRequest)
    case updateActivity(activityId: Int, request: DTO.UpdateActivityRequest)
    case deleteActivity(activityId: Int)
}

extension HobbiesTarget: BaseTargetType {
    
    var path: String {
        switch self {
        case .createHobby(_):
            return HobbiesAPI.createHobby.endpoint
            
        case .fetchAIRecommendations:
            return HobbiesAPI.fetchAIRecommendations.endpoint
            
        case .fetchActivityList(let hobbyId):
            return HobbiesAPI.fetchActivityList(hobbyId).endpoint
            
        case .createActivities(let hobbyId, _):
            return HobbiesAPI.createActivities(hobbyId).endpoint
            
        case .updateActivity(let activityId, _):
            return HobbiesAPI.updateActivity(activityId).endpoint
            
        case .deleteActivity(let activityId):
            return HobbiesAPI.deleteActivity(activityId).endpoint
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createHobby:
            return .post
        case .fetchAIRecommendations:
            return .get
        case .fetchActivityList:
            return .get
        case .createActivities:
            return .post
        case .updateActivity:
            return .patch
        case .deleteActivity:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
            
        case .createHobby(let request):
            return .requestJSONEncodable(request)
            
        case .fetchAIRecommendations, .fetchActivityList, .deleteActivity:
            return .requestPlain
            
        case .createActivities(_, let request):
            return .requestJSONEncodable(request)
            
        case .updateActivity(_, let request):
            return .requestJSONEncodable(request)
        }
    }
}
