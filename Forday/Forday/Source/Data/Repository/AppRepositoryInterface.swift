//
//  AppRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import Foundation

protocol AppRepositoryInterface {
    func fetchAppMetadata() async throws -> AppMetadata
}

final class AppRepository: AppRepositoryInterface {
    
    private let appService: AppService
    
    init(appService: AppService = AppService()) {
        self.appService = appService
    }
    
    func fetchAppMetadata() async throws -> AppMetadata {
        do {
            let response = try await appService.fetchAppMetadata()
            return response.toDomain()
        } catch {
            #if DEBUG
            print("⚠️ 앱 메타데이터 API 실패 - 목 데이터 사용")
            print("⚠️ 에러 내용: \(error)")
            return makeMockData()
            #else
            throw error
            #endif
        }
    }
    
    #if DEBUG
    private func makeMockData() -> AppMetadata {
        return AppMetadata(
            appVersion: "1.0.0",
            hobbyCards: [
                HobbyCard(id: 1, name: "그림 그리기", description: "다양한 도구로 그림 연습하기", imageAsset: .drawing),
                HobbyCard(id: 2, name: "헬스", description: "건강한 몸 만들기", imageAsset: .gym),
                HobbyCard(id: 3, name: "독서", description: "책을 읽으며 생각 넓히기", imageAsset: .reading),
                HobbyCard(id: 4, name: "음악 듣기", description: "좋아하는 스타일의 음악 듣기", imageAsset: .music),
                HobbyCard(id: 5, name: "러닝", description: "목표 거리를 정해 달리기", imageAsset: .running),
                HobbyCard(id: 6, name: "요리", description: "맛있는 음식 직접 만들기", imageAsset: .cooking),
                HobbyCard(id: 7, name: "카페 탐방", description: "다양한 카페를 직접 방문", imageAsset: .cafe),
                HobbyCard(id: 8, name: "영화 보기", description: "좋아하는 영화 보며 힐링", imageAsset: .movie),
                HobbyCard(id: 9, name: "사진 촬영", description: "일상의 순간을 예술로", imageAsset: .photo),
                HobbyCard(id: 10, name: "글쓰기", description: "나를 들여다보는 글쓰기", imageAsset: .writing)
            ]
        )
    }
    #endif
}