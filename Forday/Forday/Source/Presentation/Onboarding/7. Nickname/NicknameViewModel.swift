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
    @Published var validationResult: NicknameValidationResult = .initial
    @Published var isNextButtonEnabled: Bool = false

    /// 사용자가 한 번이라도 입력을 시작했는지 여부
    private var hasStartedTyping: Bool = false
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

        // available 상태일 때만 다음 버튼 활성화
        $validationResult
            .sink { [weak self] result in
                self?.isNextButtonEnabled = (result == .available)
            }
            .store(in: &cancellables)
    }

    /// 닉네임 유효성 검사 (클라이언트 검증)
    private func validateNickname(_ text: String) {
        // 입력이 있으면 hasStartedTyping = true
        if !text.isEmpty {
            hasStartedTyping = true
        }

        // 비어있는 경우
        if text.isEmpty {
            // 한 번이라도 입력했다가 지운 경우 → .empty
            // 처음부터 입력 안 한 경우 → .initial
            validationResult = hasStartedTyping ? .empty : .initial
            return
        }

        // 한글, 영어만 허용 (숫자 제외)
        let pattern = "^[가-힣a-zA-Z]+$"
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
                    validationResult = .available
                    print("✅ 사용 가능한 닉네임")
                } else {
                    validationResult = .duplicate
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
