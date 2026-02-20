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
        setupNavigationBar()
        setupTextField()
        setupActions()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 네비게이션 바 보이기
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setupNavigationBar() {
        // Progress bar 숨기기
        hideProgressBar()

        // 커스텀 뒤로가기 버튼 (로그인 화면으로 이동)
        let backButton = UIBarButtonItem(
            image: .Icon.chevronLeft,
            style: .plain,
            target: self,
            action: #selector(backToLogin)
        )
        backButton.tintColor = .neutral900
        navigationItem.leftBarButtonItem = backButton

        // Swipe back gesture 비활성화
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    @objc private func backToLogin() {
        // 온보딩 dismiss하고 로그인 화면으로
        coordinator?.dismissOnboarding()
    }
    
    // Actions

    override func nextButtonTapped() {
        // 다음 버튼 비활성화 (중복 클릭 방지)
        setNextButtonEnabled(false)

        Task {
            do {
                // 닉네임 설정 API 호출
                try await viewModel.setNickname()

                // 성공 시 홈으로
                await MainActor.run {
                    if let onboardingCoordinator = coordinator as? OnboardingCoordinator {
                        onboardingCoordinator.finishOnboarding()
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
        let message: String
        if let appError = error as? AppError {
            message = appError.userMessage
        } else {
            message = error.localizedDescription
        }
        ToastView.showError(message: message)
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
        // 유효성 검사 결과 → 메시지 + 버튼 상태 업데이트
        viewModel.$validationResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.nicknameView.updateValidationState(result)
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

        return true  // 모든 입력 허용, ViewModel이 validation 처리
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
