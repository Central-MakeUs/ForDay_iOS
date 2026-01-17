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
    case fetchHomeInfo(hobbyId: Int?)
    case fetchOthersActivities(hobbyId: Int)
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

        case .fetchHomeInfo:
            return HobbiesAPI.fetchHomeInfo.endpoint

        case .fetchOthersActivities:
            return HobbiesAPI.fetchOthersActivities.endpoint

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
        case .fetchHomeInfo:
            return .get
        case .fetchOthersActivities:
            return .get
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

        case .fetchHomeInfo(let hobbyId):
            if let hobbyId = hobbyId {
                return .requestParameters(parameters: ["hobbyId": hobbyId], encoding: URLEncoding.queryString)
            } else {
                return .requestPlain
            }
            
        case .fetchOthersActivities(let hobbyId):
            return .requestParameters(parameters: ["hobbyId": hobbyId], encoding: URLEncoding.queryString)

        case .fetchAIRecommendations, .fetchActivityList, .deleteActivity:
            return .requestPlain
            
        case .createActivities(_, let request):
            return .requestJSONEncodable(request)
            
        case .updateActivity(_, let request):
            return .requestJSONEncodable(request)
        }
    }
}
