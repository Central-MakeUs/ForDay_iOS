//
//  UsersRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import Foundation

protocol UsersRepositoryInterface {
    func checkNicknameAvailability(nickname: String) async throws -> NicknameCheckResult
    func setNickname(nickname: String) async throws -> SetNicknameResult
}
