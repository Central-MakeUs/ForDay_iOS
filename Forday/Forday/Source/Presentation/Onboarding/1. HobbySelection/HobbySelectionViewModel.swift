//
//  HobbySelectionViewModel.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//


import Foundation
import Combine

class HobbySelectionViewModel {

    // MARK: - Mode

    /// 취미 선택 모드
    enum Mode {
        case firstCreation   /// 첫 취미 생성 (온보딩)
        case addHobby        /// 취미 추가 (이미 생성한 취미 제외)
    }

    // MARK: - Published Properties

    @Published var hobbies: [HobbyCard] = []
    @Published var selectedHobby: HobbyCard?
    @Published var isNextButtonEnabled: Bool = false
    @Published var isLoading: Bool = false

    /// 커스텀 취미 입력값 (셀 선택 시에도 유지)
    private(set) var customHobbyText: String?

    // Coordinator에게 데이터 전달
    var onHobbySelected: ((HobbyCard) -> Void)?

    // Mode
    private let mode: Mode

    // UseCase
    private let fetchAppMetadataUseCase: FetchAppMetadataUseCase
    private let fetchAvailableHobbiesUseCase: FetchAvailableHobbiesUseCase

    // MARK: - Initialization

    init(
        mode: Mode = .firstCreation,
        fetchAppMetadataUseCase: FetchAppMetadataUseCase = FetchAppMetadataUseCase(),
        fetchAvailableHobbiesUseCase: FetchAvailableHobbiesUseCase = FetchAvailableHobbiesUseCase()
    ) {
        self.mode = mode
        self.fetchAppMetadataUseCase = fetchAppMetadataUseCase
        self.fetchAvailableHobbiesUseCase = fetchAvailableHobbiesUseCase
    }
    
    // MARK: - Methods

    /// 취미 목록 가져오기
    func fetchHobbies() async {

        await MainActor.run {
            isLoading = true
        }

        do {
            let hobbyCards: [HobbyCard]

            switch mode {
            case .firstCreation:
                // 첫 생성: 전체 취미 목록
                let metadata = try await fetchAppMetadataUseCase.execute()
                hobbyCards = metadata.hobbyCards

            case .addHobby:
                // 추가: 이미 생성한 취미 제외
                hobbyCards = try await fetchAvailableHobbiesUseCase.execute()
            }

            await MainActor.run {
                self.hobbies = hobbyCards
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
    
    /// 커스텀 취미 설정 (셀 추가 없이 값만 보관)
    func setCustomHobby(_ title: String) {
        customHobbyText = title
        let customHobby = HobbyCard(
            id: nil,
            name: title,
            description: "나만의 취미",
            imageAsset: .drawing  // 기본 이미지
        )
        selectedHobby = customHobby
        isNextButtonEnabled = true
        onHobbySelected?(customHobby)
    }
    
    /// 선택된 취미인지 확인
    func isSelected(at index: Int) -> Bool {
        guard index < hobbies.count else { return false }
        return hobbies[index].id == selectedHobby?.id
    }

    /// 초기 취미 선택 설정 (온보딩 재개 시)
    func setInitialSelection(_ hobbyCard: HobbyCard) {
        selectedHobby = hobbyCard
        isNextButtonEnabled = true
        print("✅ 초기 취미 선택 설정: \(hobbyCard.name)")
    }
}
