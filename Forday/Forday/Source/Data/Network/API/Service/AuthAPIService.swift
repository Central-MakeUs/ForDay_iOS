//
//  AuthAPIService.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation
import Moya

final class AuthAPIService {
    
    private let provider: MoyaProvider<AuthTarget>
    
    init(provider: MoyaProvider<AuthTarget> = MoyaProvider<AuthTarget>(plugins: [MoyaLoggingPlugin()])) {
        self.provider = provider
    }
    
    // MARK: - Kakao Login
    
    func loginWithKakao(request: DTO.KakaoLoginRequest) async throws -> DTO.LoginResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.kakaoLogin(request: request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.LoginResponse.self, from: response.data)
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