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

    init(provider: MoyaProvider<AppTarget> = NetworkProvider.createProvider()) {
        self.provider = provider
    }
    
    // MARK: - 앱 리소스 다운로드

    func fetchAppMetadata() async throws -> DTO.MetadataResponse {
        return try await provider.request(.fetchAppMetadata)
    }
}
