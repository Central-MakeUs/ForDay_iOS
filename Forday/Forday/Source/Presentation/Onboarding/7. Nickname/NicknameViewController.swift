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
    private var shouldResetDuplicateCheckOnAppear = false

    // Coordinator
    weak var authCoordinator: AuthCoordinator?

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

        // Analytics: 닉네임 입력 화면 진입
        FirebaseAnalyticsService.shared.log(.nicknameDirectInputScreen)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 네비게이션 바 보이기
        navigationController?.setNavigationBarHidden(false, animated: true)

        if shouldResetDuplicateCheckOnAppear {
            shouldResetDuplicateCheckOnAppear = false
            viewModel.resetDuplicateCheck()
        }
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
        if let navigationController,
           navigationController.viewControllers.first === self {
            coordinator?.dismissOnboarding()
            authCoordinator?.showLogin()
            return
        }

        navigationController?.popViewController(animated: true)
    }
    
    // Actions

    override func nextButtonTapped() {
        // Analytics: 닉네임 등록 버튼 클릭
        FirebaseAnalyticsService.shared.log(.nicknameRegisterClick)

        // 다음 버튼 비활성화 (중복 클릭 방지)
        setNextButtonEnabled(false)

        Task { [weak self] in
            guard let self = self else { return }
            do {
                // 닉네임 설정 API 호출
                let result = try await self.viewModel.setNickname()

                // 성공 시 플로우에 맞는 다음 화면으로 이동
                await MainActor.run { [weak self] in
                    self?.routeAfterNicknameSet(nickname: result.nickname)
                }
            } catch {
                // 실패 시 에러 처리
                await MainActor.run { [weak self] in
                    self?.setNextButtonEnabled(true)
                    self?.showError(error)
                }
            }
        }
    }

    private func routeAfterNicknameSet(nickname: String) {
        if let authCoordinator {
            shouldResetDuplicateCheckOnAppear = true
            authCoordinator.showSimpleHobbySelection(nickname: nickname)
            return
        }

        if let coordinator {
            coordinator.finishOnboarding()
            return
        }

        setNextButtonEnabled(true)
        print("⚠️ 닉네임 설정 후 이동할 Coordinator가 없습니다.")
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

        // Analytics: 닉네임 입력 이벤트 (닉네임은 PII이므로 파라미터로 전송하지 않음)
//        FirebaseAnalyticsService.shared.log(.currentInputNickname)

        nicknameView.nicknameTextField.resignFirstResponder()

        // async 호출
        Task { [weak self] in
            await self?.viewModel.checkDuplicate()
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
