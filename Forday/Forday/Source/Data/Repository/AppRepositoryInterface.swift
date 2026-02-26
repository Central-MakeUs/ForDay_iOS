//
//  AppRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import Foundation

protocol AppRepositoryInterface {
    func fetchAppMetadata() async throws -> AppMetadata
    func fetchPresignedUrl(images: [ImageInput]) async throws -> [ImageUploadInfo]
    func deleteImage(imageUrl: String) async throws -> String
    func fetchVersionPolicy(platform: String, appVersion: String, build: Int) async throws -> VersionPolicy
}

final class AppRepository: AppRepositoryInterface {
    
    private let appService: AppService
    
    init(appService: AppService = AppService()) {
        self.appService = appService
    }
    
    func fetchAppMetadata() async throws -> AppMetadata {
        let response = try await appService.fetchAppMetadata()
        return response.toDomain()
    }

    func fetchPresignedUrl(images: [ImageInput]) async throws -> [ImageUploadInfo] {
        let dtoImages = images.map {
            DTO.ImageUploadInput(
                originalFilename: $0.originalFilename,
                contentType: $0.contentType,
                usage: $0.usage.rawValue,
                order: $0.order
            )
        }
        let request = DTO.PresignedUrlRequest(images: dtoImages)
        let response = try await appService.fetchPresignedUrl(request: request)
        return response.toDomain()
    }

    func deleteImage(imageUrl: String) async throws -> String {
        let request = DTO.DeleteImageRequest(imageUrl: imageUrl)
        let response = try await appService.deleteImage(request: request)
        return response.toDomain()
    }

    func fetchVersionPolicy(platform: String, appVersion: String, build: Int) async throws -> VersionPolicy {
        let response = try await appService.fetchVersionPolicy(
            platform: platform,
            appVersion: appVersion,
            build: build
        )
        return response.toDomain()
    }
}