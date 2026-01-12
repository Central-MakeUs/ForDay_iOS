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
    
    // UseCases
    private let checkNicknameDuplicateUseCase: CheckNicknameDuplicateUseCase
    private let setNicknameUseCase: SetNicknameUseCase
    
    // Initialization
    
    init(
        checkNicknameDuplicateUseCase: CheckNicknameDuplicateUseCase = CheckNicknameDuplicateUseCase(),
        setNicknameUseCase: SetNicknameUseCase = SetNicknameUseCase()
    ) {
        self.checkNicknameDuplicateUseCase = checkNicknameDuplicateUseCase
        self.setNicknameUseCase = setNicknameUseCase
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
    
    /// 닉네임 유효성 검사 (클라이언트 검증)
    private func validateNickname(_ text: String) {
        isDuplicateChecked = false
        
        if text.isEmpty {
            validationResult = .empty
            return
        }
        
        let pattern = "^[가-힣a-zA-Z0-9]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if regex?.firstMatch(in: text, range: range) == nil {
            validationResult = .invalidCharacters
            return
        }
        
        validationResult = .valid
    }
    
    /// 중복 확인 (서버 통신)
    func checkDuplicate() async {
        guard validationResult == .valid else {
            return
        }
        
        print("🔍 중복 확인 시작: \(nickname)")
        
        do {
            let isAvailable = try await checkNicknameDuplicateUseCase.execute(nickname: nickname)
            
            await MainActor.run {
                if isAvailable {
                    validationResult = .valid
                    isDuplicateChecked = true
                    print("✅ 사용 가능한 닉네임")
                } else {
                    validationResult = .duplicate
                    isDuplicateChecked = false
                    print("❌ 중복된 닉네임")
                }
            }
        } catch {
            await MainActor.run {
                print("❌ 중복 확인 실패: \(error)")
            }
        }
    }
    
    /// 닉네임 설정 (서버 저장)
    func setNickname() async throws -> SetNicknameResult {
        print("💾 닉네임 설정 시작: \(nickname)")
        let result = try await setNicknameUseCase.execute(nickname: nickname)
        print("✅ 닉네임 설정 완료: \(result.message)")
        return result
    }
}
