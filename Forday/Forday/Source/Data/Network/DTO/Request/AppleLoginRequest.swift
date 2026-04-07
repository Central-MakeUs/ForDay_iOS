//
//  AppleLoginRequest.swift
//  Forday
//
//  Created by Subeen on 2/4/26.
//


extension DTO {
    struct AppleLoginRequest: BaseRequest {
        let code: String
        let fcmToken: String
        let deviceId: String
        let deviceType: String = "IOS"
    }
}
