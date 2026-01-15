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
    case fetchAIRecommendations(hobbyId: Int)
}

extension HobbiesTarget: BaseTargetType {
    
    var path: String {
        switch self {
        case .fetchAIRecommendations:
            return HobbiesAPI.fetchAIRecommendations.endpoint
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchAIRecommendations:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchAIRecommendations(let hobbyId):
            let parameters = ["hobbyId": hobbyId]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
}
