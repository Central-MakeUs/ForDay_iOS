//
//  AuthRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

protocol AuthRepositoryInterface {
    func loginWithKakao(kakaoAccessToken: String) async throws -> AuthToken
    func loginWithApple(appleIdentityToken: String) async throws -> AuthToken
    func loginAsGuest() async throws -> AuthToken
    func refreshToken(refreshToken: String) async throws -> AuthToken
    func logout() async throws
}