//
//  FrequencySelectionViewModel.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import Foundation
import Combine

class FrequencySelectionViewModel {
    
    // Published Properties
    
    @Published var frequencies: [FrequencyModel] = []
    @Published var selectedFrequency: FrequencyModel?
    @Published var isNextButtonEnabled: Bool = false
    
    // Initialization
    
    init() {
        loadMockData()
    }
    
    // Methods
    
    /// Mock 데이터 로드
    private func loadMockData() {
        frequencies = [
            FrequencyModel(id: "1", count: 1),
            FrequencyModel(id: "2", count: 2),
            FrequencyModel(id: "3", count: 3),
            FrequencyModel(id: "4", count: 4),
            FrequencyModel(id: "5", count: 5),
            FrequencyModel(id: "6", count: 6),
            FrequencyModel(id: "7", count: 7)
        ]
    }
    
    /// 횟수 선택
    func selectFrequency(at index: Int) {
        guard index < frequencies.count else { return }
        
        selectedFrequency = frequencies[index]
        isNextButtonEnabled = true
    }
    
    /// 해당 인덱스가 선택되었는지 확인
    func isSelected(at index: Int) -> Bool {
        guard index < frequencies.count else { return false }
        return frequencies[index].id == selectedFrequency?.id
    }
}