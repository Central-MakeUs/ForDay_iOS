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
    private let authProvider: MoyaProvider<AppTarget>

    init(
        provider: MoyaProvider<AppTarget> = NetworkProvider.createProvider(),
        authProvider: MoyaProvider<AppTarget> = NetworkProvider.createAuthProvider()
    ) {
        self.provider = provider
        self.authProvider = authProvider
    }
    
    // MARK: - 앱 리소스 다운로드

    func fetchAppMetadata() async throws -> DTO.MetadataResponse {
        return try await provider.request(.fetchAppMetadata)
    }

    // MARK: - Presigned URL 발급

    func fetchPresignedUrl(request: DTO.PresignedUrlRequest) async throws -> DTO.PresignedUrlResponse {
        return try await provider.request(.fetchPresignedUrl(request: request))
    }

    // MARK: - S3 임시 이미지 삭제

    func deleteImage(request: DTO.DeleteImageRequest) async throws -> DTO.DeleteImageResponse {
        return try await provider.request(.deleteImage(request: request))
    }

    // MARK: - 앱 버전 정책 조회 (토큰 불필요)

    func fetchVersionPolicy(
        platform: String,
        appVersion: String,
        build: Int
    ) async throws -> DTO.VersionPolicyResponse {
        return try await authProvider.request(
            .fetchVersionPolicy(platform: platform, appVersion: appVersion, build: build)
        )
    }
}
