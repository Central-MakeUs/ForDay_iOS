//
//  NicknameAvailabilityRequest.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import Foundation

extension DTO {
    // Request - Query Parameter로 전달
    struct NicknameAvailabilityRequest: BaseRequest {
        let nickname: String
    }
}
