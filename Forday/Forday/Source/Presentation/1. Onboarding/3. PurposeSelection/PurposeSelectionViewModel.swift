//
//  PurposeSelectionViewModel.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import Foundation
import Combine

class PurposeSelectionViewModel {
    
    // Published Properties
    
    @Published var purposes: [PurposeModel] = []
    @Published var selectedPurposes: [PurposeModel] = []
    @Published var isNextButtonEnabled: Bool = false
    
    // Initialization
    
    init() {
        loadMockData()
    }
    
    // Methods
    
    /// Mock 데이터 로드
    private func loadMockData() {
        purposes = [
            PurposeModel(id: "1", title: "스트레스 해소", subtitle: "마음을 편안하게"),
            PurposeModel(id: "2", title: "성장과 만족감", subtitle: "성취감을 얻기 위해"),
            PurposeModel(id: "3", title: "에너지 회복", subtitle: "기분과 활력을 되찾기 위해"),
            PurposeModel(id: "4", title: "삶의 균형 유지", subtitle: "일 중심이 아닌\n삶과의 균형을 위해")
        ]
    }
    
    /// 목적 선택/해제 토글
    func togglePurpose(at index: Int) {
        guard index < purposes.count else { return }
        
        let purpose = purposes[index]
        
        // 이미 선택되어 있으면 제거
        if let selectedIndex = selectedPurposes.firstIndex(where: { $0.id == purpose.id }) {
            selectedPurposes.remove(at: selectedIndex)
        } else {
            // 선택되어 있지 않으면 추가
            selectedPurposes.append(purpose)
        }
        
        // 최소 1개 선택해야 다음 버튼 활성화
        isNextButtonEnabled = !selectedPurposes.isEmpty
    }
    
    /// 해당 인덱스가 선택되었는지 확인
    func isSelected(at index: Int) -> Bool {
        guard index < purposes.count else { return false }
        let purpose = purposes[index]
        return selectedPurposes.contains(where: { $0.id == purpose.id })
    }
}