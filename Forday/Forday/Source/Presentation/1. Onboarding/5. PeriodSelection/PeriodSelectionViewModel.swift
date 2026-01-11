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
    
    // Initialization
    
    init() {
        loadMockData()
    }
    
    // Methods
    
    /// Mock 데이터 로드
    private func loadMockData() {
        periods = [
            PeriodModel(
                id: "1",
                title: "기간 미지정 (자율 모드)",
                subtitle: "정해두지 않고, 흐름대로",
                type: .flexible
            ),
            PeriodModel(
                id: "2",
                title: "66일 (포데이 모드)",
                subtitle: "생활에 자연스럽게 스며드는 기간",
                type: .fixed
            )
        ]
    }
    
    /// 기간 선택
    func selectPeriod(at index: Int) {
        guard index < periods.count else { return }
        
        selectedPeriod = periods[index]
        isNextButtonEnabled = true
    }
    
    /// 해당 인덱스가 선택되었는지 확인
    func isSelected(at index: Int) -> Bool {
        guard index < periods.count else { return false }
        return periods[index].id == selectedPeriod?.id
    }
}
