//
//  NicknameViewController.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import UIKit
import Combine

class NicknameViewController: BaseOnboardingViewController {
    
    // Properties
    
    private let nicknameView = NicknameView()
    private let viewModel = NicknameViewModel()
        
    // Lifecycle
    
    override func loadView() {
        view = nicknameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("닉네임")
        setupTextField()
        setupActions()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 네비게이션 바 보이기
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // Actions

    override func nextButtonTapped() {
        print("닉네임 설정 완료: \(viewModel.nickname)")
        
        // 다음 버튼 비활성화 (중복 클릭 방지)
        setNextButtonEnabled(false)
        
        Task {
            do {
                // 닉네임 설정 API 호출
                try await viewModel.setNickname()
                
                // 성공 시 홈으로
                await MainActor.run {
                    if let onboardingCoordinator = coordinator {
                        onboardingCoordinator.completeNicknameSetup()
                    }
                }
            } catch {
                // 실패 시 에러 처리
                await MainActor.run {
                    setNextButtonEnabled(true)
                    showError(error)
                }
            }
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "닉네임 설정 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// Setup

extension NicknameViewController {
    private func setupTextField() {
        nicknameView.nicknameTextField.delegate = self
        nicknameView.nicknameTextField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
    }
    
    private func setupActions() {
        nicknameView.duplicateCheckButton.addTarget(
            self,
            action: #selector(duplicateCheckButtonTapped),
            for: .touchUpInside
        )
    }
    
    private func bind() {
        // 유효성 검사 결과
        viewModel.$validationResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.nicknameView.showValidationMessage(
                    result.message
                )
            }
            .store(in: &cancellables)
        
        // 다음 버튼 활성화
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.setNextButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)
    }
    
    @objc private func textFieldDidChange() {
        let text = nicknameView.nicknameTextField.text ?? ""
        viewModel.nickname = text
    }
    
    @objc private func duplicateCheckButtonTapped() {
        // 유효성 검사 통과한 경우만
        guard viewModel.validationResult == .valid else {
            return
        }
        
        nicknameView.nicknameTextField.resignFirstResponder()
        
        // async 호출
        Task {
            await viewModel.checkDuplicate()
        }
    }
}

// UITextFieldDelegate

extension NicknameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 현재 텍스트 계산
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 10자 제한만 체크 (일단 입력은 허용)
        if updatedText.count > 10 {
            return false
        }
        
        // 입력 후 검증 (비동기로 처리)
        DispatchQueue.main.async { [weak self] in
            self?.validateInput(updatedText)
        }
        
        return true  // 모든 입력 허용
    }
    
    private func validateInput(_ text: String) {
        // 한글, 영어, 숫자만 있는지 검사
        let allowedPattern = "^[가-힣a-zA-Z0-9]*$"
        let regex = try? NSRegularExpression(pattern: allowedPattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if let match = regex?.firstMatch(in: text, range: range), match.range == range {
            // 유효한 문자만 있음 - 경고 제거
            if viewModel.validationResult == .invalidCharacters {
                viewModel.nickname = text  // ViewModel 업데이트 (자동 검증)
            }
        } else {
            // 유효하지 않은 문자 포함 - 경고 표시
            viewModel.validationResult = .invalidCharacters
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

#Preview {
    let nav = UINavigationController()
    let vc = NicknameViewController()
    nav.setViewControllers([vc], animated: false)
    return nav
}
