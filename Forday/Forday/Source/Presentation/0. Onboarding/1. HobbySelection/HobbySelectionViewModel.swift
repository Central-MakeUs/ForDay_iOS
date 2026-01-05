//
//  HobbySelectionViewModel.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//


import Foundation
import Combine

class HobbySelectionViewModel {
    
    // MARK: - Published Properties
    
    @Published var hobbies: [HobbyModel] = []
    @Published var selectedHobby: HobbyModel?
    @Published var isNextButtonEnabled: Bool = false
    
    // MARK: - Initialization
    
    init() {
        loadMockData()
    }
    
    // MARK: - Methods
    
    /// Mock 데이터 로드
    private func loadMockData() {
        hobbies = [
            HobbyModel(id: "1", title: "그림 그리기", subtitle: "다양한 도구로 그림 연습하기", imageName: "paintbrush.fill"),
            HobbyModel(id: "2", title: "헬스", subtitle: "건강한 몸 만들기", imageName: "figure.walk"),
            HobbyModel(id: "3", title: "독서", subtitle: "책을 읽으며 생각 넓히기", imageName: "book.fill"),
            HobbyModel(id: "4", title: "음악 듣기", subtitle: "좋아하는 스타일의 음악 듣기", imageName: "music.note"),
            HobbyModel(id: "5", title: "러닝", subtitle: "목표거리를 정해 달리기", imageName: "figure.run"),
            HobbyModel(id: "6", title: "요리", subtitle: "맛있는 음식 직접 만들기", imageName: "frying.pan.fill"),
            HobbyModel(id: "7", title: "카페 탐방", subtitle: "다양한 카페를 직접 방문", imageName: "cup.and.saucer.fill"),
            HobbyModel(id: "8", title: "영화 보기", subtitle: "좋아하는 영화 보며 힐링", imageName: "tv.fill"),
            HobbyModel(id: "9", title: "사진 촬영", subtitle: "일상의 순간을 예술로", imageName: "camera.fill"),
            HobbyModel(id: "10", title: "글쓰기", subtitle: "나를 돌아보는 글쓰기", imageName: "pencil.line")
        ]
    }
    
    /// 취미 선택
    func selectHobby(at index: Int) {
        guard index < hobbies.count else { return }
        
        let hobby = hobbies[index]
        
        // 같은 취미를 다시 선택하면 선택 해제
        if selectedHobby?.id == hobby.id {
            selectedHobby = nil
            isNextButtonEnabled = false
        } else {
            selectedHobby = hobby
            isNextButtonEnabled = true
        }
    }
    
    /// 커스텀 취미 추가
    func addCustomHobby(_ title: String) {
        let customHobby = HobbyModel(
            id: UUID().uuidString,
            title: title,
            subtitle: "나만의 취미",
            imageName: "star.fill"
        )
        hobbies.append(customHobby)
        selectedHobby = customHobby
        isNextButtonEnabled = true
    }
    
    /// 선택된 취미인지 확인
    func isSelected(at index: Int) -> Bool {
        guard index < hobbies.count else { return false }
        return hobbies[index].id == selectedHobby?.id
    }
}