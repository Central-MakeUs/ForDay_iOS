//
//  KakaoLoginRequest.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//

extension DTO {
    struct KakaoLoginRequest: BaseRequest {
        let kakaoAccessToken: String
        let fcmToken: String
        let deviceId: String
        let deviceType: String = "IOS"
    }
}
