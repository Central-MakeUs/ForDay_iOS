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
    
    public var headers: [String : String]? {
        return APIConstants.baseHeader
    }
}
