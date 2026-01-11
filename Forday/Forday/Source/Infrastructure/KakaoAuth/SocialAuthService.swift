//
//  SocialAuthService.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


protocol SocialAuthService {
    func login() async throws -> String
}
