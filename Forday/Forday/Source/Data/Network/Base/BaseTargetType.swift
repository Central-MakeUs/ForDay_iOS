//
//  BaseTargetType.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation
import Moya

protocol BaseTargetType: TargetType {}

extension BaseTargetType {
    public var baseURL: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]
        
        if let token = try? TokenStorage.shared.loadAccessToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
}



