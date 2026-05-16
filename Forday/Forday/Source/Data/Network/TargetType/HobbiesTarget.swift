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
    case createHobbyV2(request: DTO.CreateHobbyV2Request)
    case fetchHobbyInfoRecheck
    case fetchHomeInfo(hobbyId: Int?)
    case fetchStickerBoard(hobbyId: Int?, page: Int?, size: Int?)
    case fetchOthersActivities(hobbyId: Int)
    case fetchAIRecommendations(hobbyId: Int)
    case fetchAIActivityItems(hobbyId: Int, type: String)
    case fetchHobbyChips(status: String)
    case fetchActivityList(hobbyId: Int)
    case fetchActivityDropdownList(hobbyId: Int, size: Int?)
    case createActivities(hobbyId: Int, request: DTO.CreateActivitiesRequest)
    case updateActivity(activityId: Int, request: DTO.UpdateActivityRequest)
    case deleteActivity(activityId: Int)
    case createActivityRecord(activityId: Int, request: DTO.CreateActivityRecordRequest)
    case deleteHobby(hobbyId: Int)
    case fetchHobbySettings(hobbyStatus: String?)
    case fetchHobbySettingsV2
    case updateHobbySettingsV2(request: DTO.UpdateHobbySettingsV2Request)
    case updateHobby(hobbyId: Int, request: DTO.UpdateHobbyRequest)
    case updateHobbyTime(hobbyId: Int, request: DTO.UpdateHobbyTimeRequest)
    case updateExecutionCount(hobbyId: Int, request: DTO.UpdateExecutionCountRequest)
    case updateGoalDays(hobbyId: Int, request: DTO.UpdateGoalDaysRequest)
    case updateHobbyStatus(hobbyId: Int, request: DTO.UpdateHobbyStatusRequest)
    case updateCoverImage(request: DTO.UpdateHobbyCoverRequest)
}

extension HobbiesTarget: BaseTargetType {
    
    var path: String {
        switch self {
        case .createHobby(_):
            return HobbiesAPI.createHobby.endpoint

        case .createHobbyV2(_):
            return HobbiesAPI.createHobbyV2.endpoint

        case .fetchHobbyInfoRecheck:
            return HobbiesAPI.fetchHobbyInfoRecheck.endpoint

        case .fetchHomeInfo:
            return HobbiesAPI.fetchHomeInfo.endpoint

        case .fetchStickerBoard:
            return HobbiesAPI.fetchHomeStickerInfo.endpoint

        case .fetchOthersActivities:
            return HobbiesAPI.fetchOthersActivities.endpoint
            
        case .fetchAIRecommendations:
            return HobbiesAPI.fetchAIRecommendations.endpoint

        case .fetchAIActivityItems:
            return HobbiesAPI.fetchAIActivityItems.endpoint

        case .fetchHobbyChips:
            return HobbiesAPI.fetchHobbyChips.endpoint

        case .fetchActivityList(let hobbyId):
            return HobbiesAPI.fetchActivityList(hobbyId).endpoint
            
        case .fetchActivityDropdownList(let hobbyId, _):
            return HobbiesAPI.fetchActivityDropdownList(hobbyId).endpoint
            
        case .createActivities(let hobbyId, _):
            return HobbiesAPI.createActivities(hobbyId).endpoint
            
        case .updateActivity(let activityId, _):
            return HobbiesAPI.updateActivity(activityId).endpoint

        case .deleteActivity(let activityId):
            return HobbiesAPI.deleteActivity(activityId).endpoint

        case .createActivityRecord(let activityId, _):
            return HobbiesAPI.createActivityRecord(activityId).endpoint

        case .deleteHobby(let hobbyId):
            return HobbiesAPI.deleteHobby(hobbyId).endpoint

        case .fetchHobbySettings:
            return HobbiesAPI.fetchHobbySettings.endpoint

        case .fetchHobbySettingsV2:
            return HobbiesAPI.fetchHobbySettingsV2.endpoint

        case .updateHobbySettingsV2:
            return HobbiesAPI.updateHobbySettingsV2.endpoint

        case .updateHobby(let hobbyId, _):
            return HobbiesAPI.updateHobby(hobbyId).endpoint

        case .updateHobbyTime(let hobbyId, _):
            return HobbiesAPI.updateHobbyTime(hobbyId).endpoint

        case .updateExecutionCount(let hobbyId, _):
            return HobbiesAPI.updateExecutionCount(hobbyId).endpoint

        case .updateGoalDays(let hobbyId, _):
            return HobbiesAPI.updateGoalDays(hobbyId).endpoint

        case .updateHobbyStatus(let hobbyId, _):
            return HobbiesAPI.updateHobbyStatus(hobbyId).endpoint

        case .updateCoverImage:
            return HobbiesAPI.updateCoverImage.endpoint
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createHobby:
            return .post
        case .createHobbyV2:
            return .post
        case .fetchHobbyInfoRecheck:
            return .get
        case .fetchHomeInfo:
            return .get
        case .fetchStickerBoard:
            return .get
        case .fetchOthersActivities:
            return .get
        case .fetchAIRecommendations:
            return .get
        case .fetchAIActivityItems:
            return .get
        case .fetchHobbyChips:
            return .get
        case .fetchActivityList:
            return .get
        case .fetchActivityDropdownList:
            return .get
        case .createActivities:
            return .post
        case .updateActivity:
            return .patch
        case .deleteActivity:
            return .delete
        case .deleteHobby:
            return .delete
        case .createActivityRecord:
            return .post
        case .fetchHobbySettings:
            return .get
        case .fetchHobbySettingsV2:
            return .get
        case .updateHobbySettingsV2:
            return .put
        case .updateHobby:
            return .put
        case .updateHobbyTime:
            return .patch
        case .updateExecutionCount:
            return .patch
        case .updateGoalDays:
            return .patch
        case .updateHobbyStatus:
            return .patch
        case .updateCoverImage:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {

        case .createHobby(let request):
            return .requestJSONEncodable(request)

        case .createHobbyV2(let request):
            return .requestJSONEncodable(request)

        case .fetchHobbyInfoRecheck:
            return .requestPlain

        case .fetchHomeInfo(let hobbyId):
            if let hobbyId = hobbyId {
                return .requestParameters(parameters: ["hobbyId": hobbyId], encoding: URLEncoding.queryString)
            } else {
                return .requestPlain
            }

        case .fetchStickerBoard(let hobbyId, let page, let size):
            var parameters: [String: Any] = [:]
            if let hobbyId = hobbyId {
                parameters["hobbyId"] = hobbyId
            }
            if let page = page {
                parameters["page"] = page
            }
            if let size = size {
                parameters["size"] = size
            }
            if parameters.isEmpty {
                return .requestPlain
            } else {
                return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
            }

        case .fetchOthersActivities(let hobbyId):
            return .requestParameters(parameters: ["hobbyId": hobbyId], encoding: URLEncoding.queryString)
            
        case .fetchAIRecommendations(let hobbyId):
            return .requestParameters(parameters: ["hobbyId": hobbyId], encoding: URLEncoding.queryString)

        case .fetchAIActivityItems(let hobbyId, let type):
            return .requestParameters(parameters: ["hobbyId": hobbyId, "type": type], encoding: URLEncoding.queryString)

        case .fetchHobbyChips(let status):
            return .requestParameters(parameters: ["status": status], encoding: URLEncoding.queryString)

        case .fetchActivityList:
            return .requestPlain
        
        case .fetchActivityDropdownList(_, let size):
            if let size = size {
                return .requestParameters(parameters: ["size": size], encoding: URLEncoding.queryString)
            } else {
                return .requestPlain
            }
            
        case .deleteActivity:
            return .requestPlain

        case .deleteHobby:
            return .requestPlain

        case .createActivities(_, let request):
            return .requestJSONEncodable(request)

        case .updateActivity(_, let request):
            return .requestJSONEncodable(request)

        case .createActivityRecord(_, let request):
            return .requestJSONEncodable(request)

        case .fetchHobbySettings(let hobbyStatus):
            if let status = hobbyStatus {
                return .requestParameters(parameters: ["hobbyStatus": status], encoding: URLEncoding.queryString)
            } else {
                return .requestPlain
            }

        case .fetchHobbySettingsV2:
            return .requestPlain

        case .updateHobbySettingsV2(let request):
            return .requestJSONEncodable(request)

        case .updateHobby(_, let request):
            return .requestJSONEncodable(request)

        case .updateHobbyTime(_, let request):
            return .requestJSONEncodable(request)

        case .updateExecutionCount(_, let request):
            return .requestJSONEncodable(request)

        case .updateGoalDays(_, let request):
            return .requestJSONEncodable(request)

        case .updateHobbyStatus(_, let request):
            return .requestJSONEncodable(request)

        case .updateCoverImage(let request):
            return .requestJSONEncodable(request)
        }
    }
}
