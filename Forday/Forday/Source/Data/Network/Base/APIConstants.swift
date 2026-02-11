//
//  APIConstants.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation

struct APIConstants {
    static let baseURL: String = {
        #if targetEnvironment(simulator)
        return "http://localhost:8080"
        #else
        guard let ip = Bundle.main.infoDictionary?["LOCAL_MAC_IP"] as? String else {
            fatalError("LOCAL_MAC_IP not found in Info.plist")
        }
        return "http://\(ip):8080"
        #endif
    }()
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
