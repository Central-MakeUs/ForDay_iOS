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
        // Authorization 헤더는 TokenRefreshInterceptor에서 자동 추가
        return ["Content-Type": "application/json"]
    }
}



