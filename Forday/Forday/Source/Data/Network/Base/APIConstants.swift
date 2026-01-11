//
//  APIConstants.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation

struct APIConstants {
    static let baseURL = "http://forday-alb-1599562729.ap-northeast-2.elb.amazonaws.com"
    static let contentType = "Content-Type"
    static let applicationJson = "application/json"
}

extension APIConstants {
    static var baseHeader: Dictionary<String, String> {
        [
            contentType : applicationJson
        ]
    }
}
