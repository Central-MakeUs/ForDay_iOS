//
//  UsersService.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import Foundation
import Moya

final class UsersService {
    
    private let provider: MoyaProvider<UsersTarget>
    
    init(provider: MoyaProvider<UsersTarget> = NetworkProvider.createProvider()) {
        self.provider = provider
    }
    
    /// Users - 닉네임 중복 검사
    func checkNicknameAvailability(nickname: String) async throws -> DTO.NicknameAvailabilityResponse {
        return try await provider.request(.nicknameAvailability(nickname: nickname))
    }
    
    /// Users - 닉네임 설정
    func setNickname(request: DTO.SetNicknameRequest) async throws -> DTO.SetNicknameResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.setNickname(request: request)) { result in
                switch result {
                case .success(let response):
                    // 409 Conflict 체크
                    if response.statusCode == 409 {
                        let error = NSError(
                            domain: "UsersService",
                            code: 409,
                            userInfo: [NSLocalizedDescriptionKey: "이미 사용 중인 닉네임입니다."]
                        )
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.SetNicknameResponse.self, from: response.data)
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
    
    /// Users - 사용자 피드 목록 조회
    func fetchFeeds(hobbyIds: [Int], lastRecordId: Int?, feedSize: Int = 24) async throws -> DTO.UsersFeedsResponse {
        return try await provider.request(.feeds(hobbyIds: hobbyIds, lastRecordId: lastRecordId, feedSize: feedSize))
    }
    
    /// Users - 사용자 정보 조회
    func fetchUserInfo() async throws -> DTO.UsersInfoResponse {
        return try await provider.request(.info)
    }
    
    /// Users - 사용자 프로필 이미지 설정
    func updateProfileImage(profileImageUrl: String?) async throws -> DTO.UsersProfileImageUploadResponse {
        return try await provider.request(.profileImageUpload(profileImageUrl: profileImageUrl))
    }

    /// Users - 사용자 취미 진행 상단탭 조회
    func fetchHobbiesInProgress() async throws -> DTO.UsersHobbiesInProgressResponse {
        return try await provider.request(.hobbiesInProgress)
    }

    /// Users - 사용자 취미 카드 리스트 조회
    func fetchHobbyCards(lastHobbyCardId: Int?, size: Int = 20) async throws -> DTO.UsersHobbyCardResponse {
        return try await provider.request(.hobbyCards(lastHobbyCardId: lastHobbyCardId, size: size))
    }

    /// Users - 사용자 스크랩 목록 조회
    func fetchScraps(lastRecordId: Int?, feedSize: Int = 24) async throws -> DTO.UsersScrapsResponse {
        return try await provider.request(.scraps(lastRecordId: lastRecordId, feedSize: feedSize))
    }
}
