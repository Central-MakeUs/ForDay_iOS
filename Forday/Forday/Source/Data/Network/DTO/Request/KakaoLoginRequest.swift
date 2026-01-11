//
//  KakaoLoginRequest.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

extension DTO {
    struct KakaoLoginRequest: BaseRequest {
        let kakaoAccessToken: String
    }
}
