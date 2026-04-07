//
//  LoginResponse.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//

extension DTO {

    struct LoginResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: LoginData
    }

    struct LoginData: Codable {
        let accessToken: String
        let refreshToken: String
        let newUser: Bool
        let socialType: String
        let guestUserId: String?
        let onboardingCompleted: Bool
        let nicknameSet: Bool
        let onboardingData: OnboardingHobbyData?
        let termsConsentCompleted: Bool?  // Optional - 서버가 아직 반환 안 함
        let fcmToken: String?
    }

    struct OnboardingHobbyData: Codable {
        let id: Int
        let hobbyInfoId: Int
        let hobbyName: String
        let hobbyPurpose: String
        let hobbyTimeMinutes: Int
        let executionCount: Int
        let durationSet: Bool
    }
}

extension DTO.LoginData {
    func toDomain() -> AuthToken {
        return AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: newUser,
            socialType: SocialType(rawValue: socialType) ?? .guest,
            guestUserId: guestUserId,
            onboardingCompleted: onboardingCompleted,
            nicknameSet: nicknameSet,
            onboardingData: onboardingData?.toDomain(),
            termsConsentCompleted: termsConsentCompleted ?? false  // 서버가 없으면 false (약관동의 필요)
        )
    }
}

extension DTO.OnboardingHobbyData {
    func toDomain() -> SavedOnboardingData {
        return SavedOnboardingData(
            id: id,
            hobbyInfoId: hobbyInfoId,
            hobbyName: hobbyName,
            hobbyPurpose: hobbyPurpose,
            hobbyTimeMinutes: hobbyTimeMinutes,
            executionCount: executionCount,
            durationSet: durationSet
        )
    }
}
