//
//  KeyChainManager.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation
import Security

final class KeyChainManager {
    
    static let shared = KeyChainManager()
    private init() {}
    
    enum KeyChainError: Error {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
    }
    
    // MARK: - Save
    
    func save(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeyChainError.unexpectedStatus(errSecParam)
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            try update(key: key, value: value)
        } else if status != errSecSuccess {
            throw KeyChainError.unexpectedStatus(status)
        }
    }
    
    // MARK: - Load
    
    func load(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeyChainError.itemNotFound
            }
            throw KeyChainError.unexpectedStatus(status)
        }
        
        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeyChainError.unexpectedStatus(errSecParam)
        }
        
        return value
    }
    
    // MARK: - Update
    
    private func update(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeyChainError.unexpectedStatus(errSecParam)
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeyChainError.unexpectedStatus(status)
        }
    }
    
    // MARK: - Delete
    
    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeyChainError.unexpectedStatus(status)
        }
    }
}