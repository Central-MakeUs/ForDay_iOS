//
//  TokenStorage.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

final class TokenStorage {
    
    static let shared = TokenStorage()
    private let keyChain = KeyChainManager.shared
    
    private init() {}
    
    private enum Key {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }
    
    // MARK: - Save
    
    func saveTokens(accessToken: String, refreshToken: String) throws {
        try keyChain.save(key: Key.accessToken, value: accessToken)
        try keyChain.save(key: Key.refreshToken, value: refreshToken)
    }
    
    // MARK: - Load
    
    func loadAccessToken() throws -> String {
        return try keyChain.load(key: Key.accessToken)
    }
    
    func loadRefreshToken() throws -> String {
        return try keyChain.load(key: Key.refreshToken)
    }
    
    // MARK: - Delete
    
    func deleteTokens() throws {
        try keyChain.delete(key: Key.accessToken)
        try keyChain.delete(key: Key.refreshToken)
    }
}
