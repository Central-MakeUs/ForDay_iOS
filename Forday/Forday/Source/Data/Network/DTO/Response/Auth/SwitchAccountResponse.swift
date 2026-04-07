//
//  SwitchAccountResponse.swift
//  Forday
//
//  Created by Subeen on 2/4/26.
//

extension DTO {

    struct SwitchAccountResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: SwitchAccountData
    }

    struct SwitchAccountData: Codable {
        let socialType: String
        let accessToken: String
        let refreshToken: String
        let fcmToken: String?
    }
}

extension DTO.SwitchAccountData {
    func toDomain() -> AuthToken {
        return AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: false,
            socialType: SocialType(rawValue: socialType) ?? .kakao,
            guestUserId: nil,
            onboardingCompleted: true,
            nicknameSet: true,
            onboardingData: nil,
            termsConsentCompleted: true  // 계정 전환은 이미 약관 동의한 상태
        )
    }
}
