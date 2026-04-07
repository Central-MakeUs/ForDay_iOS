//
//  SwitchAccountRequest.swift
//  Forday
//
//  Created by Subeen on 2/4/26.
//

extension DTO {
    struct SwitchAccountRequest: BaseRequest {
        let socialType: String
        let socialCode: String
        let fcmToken: String
        let deviceId: String
        let deviceType: String = "IOS"
    }
}
