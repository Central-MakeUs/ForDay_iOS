//
//  FetchAppMetadataUseCase.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import Foundation

final class FetchAppMetadataUseCase {
    
    private let repository: AppRepositoryInterface
    
    init(repository: AppRepositoryInterface = AppRepository()) {
        self.repository = repository
    }
    
    func execute() async throws -> AppMetadata {
        return try await repository.fetchAppMetadata()
    }
}