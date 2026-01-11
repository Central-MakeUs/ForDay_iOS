//
//  LoginResponse.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

extension DTO {

    struct LoginResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: LoginData
    }

    struct LoginData: Decodable {
        let accessToken: String
        let refreshToken: String
        let newUser: Bool
        let socialType: String
    }
}

extension DTO.LoginData {
    func toDomain() -> AuthToken {
        AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: newUser,
            socialType: SocialType(rawValue: socialType) ?? .kakao
        )
    }
}
