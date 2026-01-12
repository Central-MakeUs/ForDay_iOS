//
//  SetNicknameUseCase.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import Foundation

struct SetNicknameUseCase {
    
    private let usersRepository: UsersRepositoryInterface
    
    init(usersRepository: UsersRepositoryInterface = UsersRepository()) {
        self.usersRepository = usersRepository
    }
    
    func execute(nickname: String) async throws -> SetNicknameResult {
        try await usersRepository.setNickname(nickname: nickname)
    }
}
