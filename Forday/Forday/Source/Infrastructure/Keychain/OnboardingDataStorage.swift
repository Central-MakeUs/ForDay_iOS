//
//  OnboardingDataStorage.swift
//  Forday
//
//  Created by Subeen on 1/13/26.
//


import Foundation

final class OnboardingDataStorage {
    
    static let shared = OnboardingDataStorage()
    private let keyChain = KeyChainManager.shared
    
    private init() {}
    
    private enum Key {
        static let onboardingData = "onboardingData"
    }
    
    // MARK: - Save
    
    func save(_ data: OnboardingData) throws {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "OnboardingDataStorage", code: -1)
        }
        try keyChain.save(key: Key.onboardingData, value: jsonString)
    }
    
    // MARK: - Load
    
    func load() throws -> OnboardingData {
        let jsonString = try keyChain.load(key: Key.onboardingData)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw KeyChainManager.KeyChainError.itemNotFound
        }
        let decoder = JSONDecoder()
        return try decoder.decode(OnboardingData.self, from: jsonData)
    }
    
    // MARK: - Delete
    
    func delete() throws {
        try keyChain.delete(key: Key.onboardingData)
    }
    
    // MARK: - Check Exists
    
    func hasData() -> Bool {
        do {
            _ = try load()
            return true
        } catch {
            return false
        }
    }
}
