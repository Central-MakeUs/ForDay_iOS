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
        // 온보딩 완료 후라 프로그래스바 없음
    }
    
    // Actions
    
    override func nextButtonTapped() {
        print("닉네임 설정 완료: \(viewModel.nickname)")
        // TODO: 다음 화면으로
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
                self?.nicknameView.showValidationMessage(result.message)
            }
            .store(in: &cancellables)
        
        // 다음 버튼 활성화
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.setNextButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)
        
        // 중복 확인 완료
        viewModel.$isDuplicateChecked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isChecked in
                if isChecked {
                    self?.nicknameView.showValidationMessage("사용 가능한 닉네임입니다.", isError: false)
                }
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
        viewModel.checkDuplicate()
    }
}

// UITextFieldDelegate

extension NicknameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 10자 제한
        return updatedText.count <= 10
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