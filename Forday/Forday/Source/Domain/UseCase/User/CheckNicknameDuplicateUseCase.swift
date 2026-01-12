//
//  CheckNicknameDuplicateUseCase.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import Foundation

struct CheckNicknameDuplicateUseCase {
    
    private let usersRepository: UsersRepositoryInterface
    
    init(usersRepository: UsersRepositoryInterface = UsersRepository()) {
        self.usersRepository = usersRepository
    }
    
    func execute(nickname: String) async throws -> Bool {
        let result = try await usersRepository.checkNicknameAvailability(nickname: nickname)
        return result.isAvailable
    }
}
