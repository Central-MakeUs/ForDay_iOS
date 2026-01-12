//
//  UsersService.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import Foundation
import Moya

final class UsersService {
    
    private let provider: MoyaProvider<UsersTarget>
    
    init(provider: MoyaProvider<UsersTarget> = MoyaProvider<UsersTarget>(plugins: [MoyaLoggingPlugin()])) {
        self.provider = provider
    }
    
    /// Users - 닉네임 중복 검사
    func checkNicknameAvailability(nickname: String) async throws -> DTO.NicknameAvailabilityResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.nicknameAvailability(nickname: nickname)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.NicknameAvailabilityResponse.self, from: response.data)
                        continuation.resume(returning: decodedResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Users - 닉네임 설정
    func setNickname(request: DTO.SetNicknameRequest) async throws -> DTO.SetNicknameResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.setNickname(request: request)) { result in
                switch result {
                case .success(let response):
                    // 409 Conflict 체크
                    if response.statusCode == 409 {
                        let error = NSError(
                            domain: "UsersService",
                            code: 409,
                            userInfo: [NSLocalizedDescriptionKey: "이미 사용 중인 닉네임입니다."]
                        )
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.SetNicknameResponse.self, from: response.data)
                        continuation.resume(returning: decodedResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
