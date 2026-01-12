//
//  UsersRepository.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//

import Foundation

final class UsersRepository: UsersRepositoryInterface {
    
    private let usersService: UsersService
    
    init(usersService: UsersService = UsersService()) {
        self.usersService = usersService
    }
    
    // MARK: - Nickname Availability Check
    
    func checkNicknameAvailability(nickname: String) async throws -> NicknameCheckResult {
        let response = try await usersService.checkNicknameAvailability(nickname: nickname)
        return response.toDomain()
    }
    
    // MARK: - Set Nickname
    
    // UsersRepository.swift
    func setNickname(nickname: String) async throws -> SetNicknameResult {
        let request = DTO.SetNicknameRequest(nickname: nickname)
        let response = try await usersService.setNickname(request: request)
        return response.toDomain()
    }
}
