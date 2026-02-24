//
//  APIConstants.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation

struct APIConstants {
    static let baseURL: String = {
        #if DEBUG
        // 개발 환경: 로컬 서버 사용
        #if targetEnvironment(simulator)
        return "https://forday.kr"
        #else
        guard let ip = Bundle.main.infoDictionary?["LOCAL_MAC_IP"] as? String else {
            fatalError("LOCAL_MAC_IP not found in Info.plist")
        }
        return "http://\(ip):8080"
        #endif
        #else
        // 배포 환경: Config.xcconfig의 BASE_URL 사용
        guard let baseURL = Bundle.main.infoDictionary?["BASE_URL"] as? String else {
            fatalError("BASE_URL not found in Info.plist")
        }
        return baseURL
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
