//
//  AuthToken.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

struct AuthToken {
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
    let socialType: SocialType
}
