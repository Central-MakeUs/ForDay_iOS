//
//  AppService.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//

import Foundation
import Moya

final class AppService {
    
    private let provider: MoyaProvider<AppTarget>
    
    init(provider: MoyaProvider<AppTarget> = MoyaProvider<AppTarget>(plugins: [MoyaLoggingPlugin()])) {
        self.provider = provider
    }
    
    // MARK: - 앱 리소스 다운로드
    
    func fetchAppMetadata() async throws -> DTO.MetadataResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.fetchAppMetadata) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.MetadataResponse.self, from: response.data)
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
