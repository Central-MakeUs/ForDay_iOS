//
//  HobbyRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

protocol HobbyRepositoryInterface {
    func createHobby(
        hobbyCardId: Int,
        hobbyName: String,
        hobbyTimeMinutes: Int,
        hobbyPurpose: String,
        executionCount: Int,
        isDurationSet: Bool
    ) async throws -> Int
}
