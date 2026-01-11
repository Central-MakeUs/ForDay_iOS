//
//  LoginResponse.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

extension DTO {
    struct LoginResponse: BaseResponse {
        let accessToken: String
        let refreshToken: String
        let newUser: Bool
        let socialType: String
        
        func toDomain() -> AuthToken {
            return AuthToken(
                accessToken: accessToken,
                refreshToken: refreshToken,
                isNewUser: newUser,
                socialType: SocialType(rawValue: socialType) ?? .kakao
            )
        }
    }
}
