//
//  MoyaProvider+Async.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation
import Moya

extension MoyaProvider {

    /// Generic async/await wrapper for Moya requests with automatic JSON decoding
    /// - Parameter target: The target endpoint to request
    /// - Returns: Decoded response of type T
    /// - Throws: Network errors or decoding errors
    func request<T: Decodable>(_ target: Target) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: response.data)
                        continuation.resume(returning: decoded)
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
