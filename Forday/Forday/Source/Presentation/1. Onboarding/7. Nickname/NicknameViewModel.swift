//
//  NicknameViewModel.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation
import Combine

class NicknameViewModel {
    
    // Published Properties
    
    @Published var nickname: String = ""
    @Published var validationResult: NicknameValidationResult = .empty
    @Published var isDuplicateChecked: Bool = false
    @Published var isNextButtonEnabled: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // Initialization
    
    init() {
        bind()
    }
    
    // Methods
    
    private func bind() {
        // 닉네임 변경 시 자동 유효성 검사
        $nickname
            .sink { [weak self] text in
                self?.validateNickname(text)
            }
            .store(in: &cancellables)
        
        // 중복 확인 완료 시 다음 버튼 활성화
        $isDuplicateChecked
            .combineLatest($validationResult)
            .sink { [weak self] isChecked, result in
                self?.isNextButtonEnabled = isChecked && result == .valid
            }
            .store(in: &cancellables)
    }
    
    /// 닉네임 유효성 검사
    private func validateNickname(_ text: String) {
        // 닉네임 변경 시 중복 확인 리셋
        isDuplicateChecked = false
        
        // 빈 값
        if text.isEmpty {
            validationResult = .empty
            return
        }
        
        // 길이 체크 (한글 기준 10자)
        if text.count > 10 {
            validationResult = .tooLong
            return
        }
        
        // 한글/영어/숫자만 허용
        let pattern = "^[가-힣a-zA-Z0-9]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if regex?.firstMatch(in: text, range: range) == nil {
            validationResult = .invalidCharacters
            return
        }
        
        // 유효함
        validationResult = .valid
    }
    
    /// 중복 확인 (서버 통신)
    func checkDuplicate() {
        // TODO: 서버 통신
        print("중복 확인 시작: \(nickname)")
        
        // 임시: 2초 후 중복 아님으로 처리
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isDuplicateChecked = true
            print("중복 확인 완료: 사용 가능")
        }
    }
}