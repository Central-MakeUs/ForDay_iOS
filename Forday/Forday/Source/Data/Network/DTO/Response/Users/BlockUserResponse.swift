//
//  BlockUserResponse.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import Foundation

extension DTO {
    struct BlockUserResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: BlockUserData?
    }

    struct BlockUserData: Codable {
        let message: String?
    }
}
