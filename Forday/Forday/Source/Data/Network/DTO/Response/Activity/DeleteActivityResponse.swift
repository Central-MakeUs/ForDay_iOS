//
//  DeleteActivityResponse.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation

extension DTO {
    struct DeleteActivityResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: MessageData
    }
}

extension DTO.DeleteActivityResponse  {
    func toDomain() -> String {
        return data.message
    }
}
