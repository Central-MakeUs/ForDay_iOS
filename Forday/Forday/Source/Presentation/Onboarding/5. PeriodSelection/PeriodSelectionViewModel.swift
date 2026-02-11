//
//  PeriodSelectionViewModel.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//


import Foundation
import Combine

class PeriodSelectionViewModel {

    // Published Properties

    @Published var periods: [PeriodModel] = []
    @Published var selectedPeriod: PeriodModel?
    @Published var isNextButtonEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Coordinator에게 데이터 전달
    var onPeriodSelected: ((Bool) -> Void)?
    var onHobbyCreated: ((Int) -> Void)?

    // UseCase
    private let createHobbyUseCase: CreateHobbyUseCase

    // Initialization

    init(createHobbyUseCase: CreateHobbyUseCase = CreateHobbyUseCase()) {
        self.createHobbyUseCase = createHobbyUseCase
        loadMockData()
    }
    
    // Methods
    
    /// 기간 옵션 로드
    private func loadMockData() {
        periods = [
            PeriodModel(id: "1", type: .flexible),
            PeriodModel(id: "2", type: .fixed)
        ]
    }
    
    /// 기간 선택
    func selectPeriod(at index: Int) {
        guard index < periods.count else { return }
        
        selectedPeriod = periods[index]
        isNextButtonEnabled = true
        
        // PeriodType → Bool 변환 후 클로저 호출
        let isDurationSet: Bool
        switch periods[index].type {
        case .flexible:
            isDurationSet = false
        case .fixed:
            isDurationSet = true
        }
        onPeriodSelected?(isDurationSet)
    }
    
    /// 해당 인덱스가 선택되었는지 확인
    func isSelected(at index: Int) -> Bool {
        guard index < periods.count else { return false }
        return periods[index].id == selectedPeriod?.id
    }

    /// 취미 생성 API 호출
    @MainActor
    func createHobby(with onboardingData: OnboardingData) async {
        isLoading = true
        errorMessage = nil

        do {
            let hobbyId = try await createHobbyUseCase.execute(onboardingData: onboardingData)
            isLoading = false
            AppEventBus.shared.hobbyCreated.send(hobbyId)
            onHobbyCreated?(hobbyId)
        } catch {
            isLoading = false

            // 409 DUPLICATE_HOBBY_REQUEST → 이미 취미 존재, 닉네임 설정으로 이동
            if case .server(let serverError) = error as? AppError,
               serverError.statusCode == 409 {
                onHobbyCreated?(0)
                return
            }

            errorMessage = error.localizedDescription
            print("❌ 취미 생성 실패: \(error)")
        }
    }
}
