//
//  UsersInfoResponse.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

extension DTO {
    struct UsersInfoResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UsersInfoData

        struct UsersInfoData: Codable {
            let profileImageUrl: String?
            let nickname: String
            let totalCollectedStickerCount: Int
            let unReadNotificationExists: Bool
        }
    }
}

extension DTO.UsersInfoResponse {
    func toDomain() -> UserInfo {
        return UserInfo(
            profileImageUrl: data.profileImageUrl,
            nickname: data.nickname,
            totalCollectedStickerCount: data.totalCollectedStickerCount,
            unReadNotificationExists: data.unReadNotificationExists
        )
    }
}
