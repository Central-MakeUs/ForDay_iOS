//
//  ActivityService.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation
import Moya

import Foundation
import Moya

final class ActivityService {
    
    private let provider: MoyaProvider<HobbiesTarget>
    
    init(provider: MoyaProvider<HobbiesTarget> = MoyaProvider<HobbiesTarget>(plugins: [MoyaLoggingPlugin()])) {
        self.provider = provider
    }
    
    // MARK: - AI 추천
    
    func fetchAIRecommendations(hobbyId: Int) async throws -> DTO.AIRecommendationResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.fetchAIRecommendations(hobbyId: hobbyId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.AIRecommendationResponse.self, from: response.data)
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
    
    // MARK: - 활동 목록 조회
    
    func fetchActivityList(hobbyId: Int) async throws -> DTO.ActivityListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.fetchActivityList(hobbyId: hobbyId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.ActivityListResponse.self, from: response.data)
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
    
    // MARK: - 활동 생성
    
    func createActivities(hobbyId: Int, request: DTO.CreateActivitiesRequest) async throws -> DTO.CreateActivitiesResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.createActivities(hobbyId: hobbyId, request: request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.CreateActivitiesResponse.self, from: response.data)
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
    
    // MARK: - 활동 수정
    
    func updateActivity(activityId: Int, request: DTO.UpdateActivityRequest) async throws -> DTO.UpdateActivityResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.updateActivity(activityId: activityId, request: request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.UpdateActivityResponse.self, from: response.data)
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
    
    // MARK: - 활동 삭제
    
    func deleteActivity(activityId: Int) async throws -> DTO.DeleteActivityResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.deleteActivity(activityId: activityId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.DeleteActivityResponse.self, from: response.data)
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
