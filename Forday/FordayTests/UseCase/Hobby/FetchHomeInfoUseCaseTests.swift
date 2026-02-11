//
//  FetchHomeInfoUseCaseTests.swift
//  FordayTests
//
//  Created by Subeen on 2/10/26.
//

import Testing
@testable import Forday

@Suite("FetchHomeInfoUseCase 테스트")
struct FetchHomeInfoUseCaseTests {

    // MARK: - 성공 케이스

    @Test("홈 정보 조회 성공")
    func fetchHomeInfo_success() async throws {
        // Given
        let mockRepo = MockHobbyRepository()
        mockRepo.homeInfoToReturn = HomeInfo(
            inProgressHobbies: [
                InProgressHobby(hobbyId: 1, hobbyName: "그림", currentHobby: true),
                InProgressHobby(hobbyId: 2, hobbyName: "독서", currentHobby: false)
            ],
            activityPreview: ActivityPreview(
                activityId: 100,
                content: "오늘 30분 그림 연습",
                aiRecommended: false
            ),
            greetingMessage: "좋은 아침이에요!",
            userSummaryText: "3일째 열심히 하고 있어요",
            recommendMessage: "오늘도 화이팅!",
            aiCallRemaining: true
        )

        let sut = FetchHomeInfoUseCase(repository: mockRepo)

        // When
        let result = try await sut.execute(hobbyId: 1)

        // Then
        #expect(result != nil)
        #expect(result?.inProgressHobbies.count == 2)
        #expect(result?.inProgressHobbies.first?.hobbyName == "그림")
        #expect(result?.greetingMessage == "좋은 아침이에요!")
        #expect(result?.activityPreview?.activityId == 100)
        #expect(result?.aiCallRemaining == true)
        #expect(mockRepo.fetchHomeInfoCallCount == 1)
        #expect(mockRepo.lastFetchHomeInfoHobbyId == 1)
    }

    @Test("hobbyId 없이 조회 성공")
    func fetchHomeInfo_withoutHobbyId_success() async throws {
        // Given
        let mockRepo = MockHobbyRepository()
        mockRepo.homeInfoToReturn = HomeInfo(
            inProgressHobbies: [],
            activityPreview: nil,
            greetingMessage: "안녕하세요",
            userSummaryText: "",
            recommendMessage: "",
            aiCallRemaining: false
        )

        let sut = FetchHomeInfoUseCase(repository: mockRepo)

        // When
        let result = try await sut.execute()

        // Then
        #expect(result != nil)
        #expect(result?.inProgressHobbies.isEmpty == true)
        #expect(mockRepo.lastFetchHomeInfoHobbyId == nil)
    }

    @Test("진행 중인 취미가 없을 때")
    func fetchHomeInfo_noHobbies() async throws {
        // Given
        let mockRepo = MockHobbyRepository()
        mockRepo.homeInfoToReturn = HomeInfo(
            inProgressHobbies: [],
            activityPreview: nil,
            greetingMessage: "취미를 시작해보세요!",
            userSummaryText: "",
            recommendMessage: "새로운 취미를 등록해보세요",
            aiCallRemaining: true
        )

        let sut = FetchHomeInfoUseCase(repository: mockRepo)

        // When
        let result = try await sut.execute()

        // Then
        #expect(result?.inProgressHobbies.isEmpty == true)
        #expect(result?.activityPreview == nil)
    }

    @Test("nil 반환 시")
    func fetchHomeInfo_returnsNil() async throws {
        // Given
        let mockRepo = MockHobbyRepository()
        mockRepo.homeInfoToReturn = nil

        let sut = FetchHomeInfoUseCase(repository: mockRepo)

        // When
        let result = try await sut.execute()

        // Then
        #expect(result == nil)
    }

    // MARK: - 실패 케이스

    @Test("네트워크 에러 시 throw")
    func fetchHomeInfo_networkError_throws() async {
        // Given
        let mockRepo = MockHobbyRepository()
        mockRepo.errorToThrow = AppError.network(.noInternet)

        let sut = FetchHomeInfoUseCase(repository: mockRepo)

        // When & Then
        await #expect(throws: AppError.self) {
            try await sut.execute()
        }
    }

    @Test("서버 에러 시 throw")
    func fetchHomeInfo_serverError_throws() async {
        // Given
        let mockRepo = MockHobbyRepository()
        mockRepo.errorToThrow = AppError.server(ServerError(
            errorClassName: "HOBBY_NOT_FOUND",
            message: "취미를 찾을 수 없습니다",
            statusCode: 404
        ))

        let sut = FetchHomeInfoUseCase(repository: mockRepo)

        // When & Then
        await #expect(throws: AppError.self) {
            try await sut.execute(hobbyId: 999)
        }
    }

    @Test("타임아웃 에러 시 throw")
    func fetchHomeInfo_timeoutError_throws() async {
        // Given
        let mockRepo = MockHobbyRepository()
        mockRepo.errorToThrow = AppError.network(.timeout)

        let sut = FetchHomeInfoUseCase(repository: mockRepo)

        // When & Then
        await #expect(throws: AppError.self) {
            try await sut.execute()
        }
    }

    // MARK: - 파라미터화 테스트

    @Test("여러 hobbyId로 조회", arguments: [1, 2, 100, 999])
    func fetchHomeInfo_variousHobbyIds(hobbyId: Int) async throws {
        // Given
        let mockRepo = MockHobbyRepository()
        mockRepo.homeInfoToReturn = HomeInfo(
            inProgressHobbies: [],
            activityPreview: nil,
            greetingMessage: "",
            userSummaryText: "",
            recommendMessage: "",
            aiCallRemaining: false
        )

        let sut = FetchHomeInfoUseCase(repository: mockRepo)

        // When
        let _ = try await sut.execute(hobbyId: hobbyId)

        // Then
        #expect(mockRepo.lastFetchHomeInfoHobbyId == hobbyId)
        #expect(mockRepo.fetchHomeInfoCallCount == 1)
    }

    // MARK: - 호출 횟수 테스트

    @Test("여러 번 호출 시 카운트 증가")
    func fetchHomeInfo_multipleCallsTracked() async throws {
        // Given
        let mockRepo = MockHobbyRepository()
        mockRepo.homeInfoToReturn = HomeInfo(
            inProgressHobbies: [],
            activityPreview: nil,
            greetingMessage: "",
            userSummaryText: "",
            recommendMessage: "",
            aiCallRemaining: false
        )

        let sut = FetchHomeInfoUseCase(repository: mockRepo)

        // When
        let _ = try await sut.execute(hobbyId: 1)
        let _ = try await sut.execute(hobbyId: 2)
        let _ = try await sut.execute(hobbyId: 3)

        // Then
        #expect(mockRepo.fetchHomeInfoCallCount == 3)
        #expect(mockRepo.lastFetchHomeInfoHobbyId == 3)
    }
}
