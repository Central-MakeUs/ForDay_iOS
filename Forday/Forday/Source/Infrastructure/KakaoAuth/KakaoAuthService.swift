//
//  SocialAuthService.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation
import KakaoSDKAuth
import KakaoSDKUser


final class KakaoAuthService: SocialAuthService {
    
    enum KakaoAuthError: Error {
        case tokenNotFound
        case loginFailed(Error)
    }
    
    func login() async throws -> String {
        // 카카오톡 앱이 설치되어 있는지 확인
        if UserApi.isKakaoTalkLoginAvailable() {
            // 카카오톡 앱으로 로그인
            return try await loginWithKakaoTalk()
        } else {
            // 카카오 계정으로 로그인 (웹)
            return try await loginWithKakaoAccount()
        }
    }
    
    // MARK: - Private Methods
    
    private func loginWithKakaoTalk() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    continuation.resume(throwing: KakaoAuthError.loginFailed(error))
                } else if let accessToken = oauthToken?.accessToken {
                    continuation.resume(returning: accessToken)
                } else {
                    continuation.resume(throwing: KakaoAuthError.tokenNotFound)
                }
            }
        }
    }
    
    private func loginWithKakaoAccount() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    continuation.resume(throwing: KakaoAuthError.loginFailed(error))
                } else if let accessToken = oauthToken?.accessToken {
                    continuation.resume(returning: accessToken)
                } else {
                    continuation.resume(throwing: KakaoAuthError.tokenNotFound)
                }
            }
        }
    }
}
