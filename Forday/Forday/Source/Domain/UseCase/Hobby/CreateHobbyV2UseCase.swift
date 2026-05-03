//
//  CreateHobbyV2UseCase.swift
//  Forday
//
//  Created by Subeen on 1/18/26.
//

import Foundation

/// v2 API: 여러 개 취미를 한번에 생성 (새 회원가입 플로우용)
struct CreateHobbyV2UseCase {

    private let hobbyRepository: HobbyRepositoryInterface

    init(hobbyRepository: HobbyRepositoryInterface = HobbyRepository()) {
        self.hobbyRepository = hobbyRepository
    }

    /// 선택한 취미 목록으로 취미 생성
    /// - Parameter hobbies: [(hobbyInfoId, hobbyName)] 형태의 튜플 배열
    /// - Returns: 생성된 취미 ID 배열
    func execute(hobbies: [(hobbyInfoId: Int?, hobbyName: String)]) async throws -> [Int] {
        guard !hobbies.isEmpty else {
            throw AppError.validation("최소 1개의 취미를 선택해야 합니다.")
        }

        guard hobbies.count <= 10 else {
            throw AppError.validation("취미는 최대 10개까지 선택할 수 있습니다.")
        }

        return try await hobbyRepository.createHobbyV2(hobbies: hobbies)
    }
}
