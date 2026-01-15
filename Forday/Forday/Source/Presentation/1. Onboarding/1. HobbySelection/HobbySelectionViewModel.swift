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
    
    @Published var hobbies: [HobbyCard] = []
    @Published var selectedHobby: HobbyCard?
    @Published var isNextButtonEnabled: Bool = false
    @Published var isLoading: Bool = false
    
    // Coordinator에게 데이터 전달
    var onHobbySelected: ((HobbyCard) -> Void)?
    
    // UseCase
    private let fetchAppMetadataUseCase: FetchAppMetadataUseCase
    
    // MARK: - Initialization
    
    init(fetchAppMetadataUseCase: FetchAppMetadataUseCase = FetchAppMetadataUseCase()) {
        self.fetchAppMetadataUseCase = fetchAppMetadataUseCase
    }
    
    // MARK: - Methods
    
    /// 취미 목록 가져오기
    func fetchHobbies() async {
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let metadata = try await fetchAppMetadataUseCase.execute()
            
            await MainActor.run {
                self.hobbies = metadata.hobbyCards
                print("✅ 취미 목록 로드 완료: \(metadata.hobbyCards.count)개")
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                print("❌ 취미 목록 로드 실패: \(error)")
                self.isLoading = false
            }
        }
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
        
        // 클로저 호출
        if let selectedHobby = selectedHobby {
            onHobbySelected?(selectedHobby)
        }
    }
    
    /// 커스텀 취미 추가
    func addCustomHobby(_ title: String) {
        let customHobby = HobbyCard(
            id: nil,
            name: title,
            description: "나만의 취미",
            imageAsset: .drawing  // 기본 이미지
        )
        hobbies.append(customHobby)
        selectedHobby = customHobby
        isNextButtonEnabled = true
        
        // 클로저 호출
        onHobbySelected?(customHobby)
    }
    
    /// 선택된 취미인지 확인
    func isSelected(at index: Int) -> Bool {
        guard index < hobbies.count else { return false }
        return hobbies[index].id == selectedHobby?.id
    }
}
