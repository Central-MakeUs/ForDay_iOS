//
//  LoginViewController.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import UIKit
import Combine

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private let loginView = LoginView()
    private var cancellables = Set<AnyCancellable>()
    
    // UseCase
    private let kakaoLoginUseCase: KakaoLoginUseCase
    private let appleLoginUseCase: AppleLoginUseCase
    private let guestLoginUseCase: GuestLoginUseCase
    
    // Coordinator
    weak var coordinator: AuthCoordinator?
    
    // MARK: - Initialization
    
    init(useCaseFactory: AuthUseCaseFactory = AuthUseCaseFactory()) {
        self.kakaoLoginUseCase = useCaseFactory.makeKakaoLoginUseCase()
        self.appleLoginUseCase = useCaseFactory.makeAppleLoginUseCase()
        self.guestLoginUseCase = useCaseFactory.makeGuestLoginUseCase()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()

        // Analytics: 로그인 화면 진입
        FirebaseAnalyticsService.shared.log(.loginScreen)
    }
}

// MARK: - Setup

extension LoginViewController {
    private func setupActions() {
        loginView.kakaoLoginButton.addTarget(
            self,
            action: #selector(kakaoLoginButtonTapped),
            for: .touchUpInside
        )

        loginView.appleLoginButton.addTarget(
            self,
            action: #selector(appleLoginButtonTapped),
            for: .touchUpInside
        )

        loginView.guestLoginButton.addTarget(
            self,
            action: #selector(guestLoginButtonTapped),
            for: .touchUpInside
        )

        loginView.debugSignupButton.addTarget(
            self,
            action: #selector(debugSignupButtonTapped),
            for: .touchUpInside
        )
    }
    
    // MARK: - Actions
    
    @objc private func kakaoLoginButtonTapped() {
        // Analytics: 카카오 로그인 클릭
        FirebaseAnalyticsService.shared.log(.kakaoLoginClick)

        loginView.isLoginInProgress = true
        Task { [weak self] in
            guard let self = self else { return }
            defer {
                Task { @MainActor [weak self] in
                    self?.loginView.isLoginInProgress = false
                }
            }
            do {
                let authToken = try await self.kakaoLoginUseCase.execute()
                await MainActor.run { [weak self] in
                    self?.coordinator?.handleLoginSuccess(authToken: authToken)
                }
            } catch {
                // 사용자 취소 시 에러 알림 표시하지 않음
                if self.isUserCancellationError(error) { return }
                await MainActor.run { [weak self] in
                    self?.showError(error)
                }
            }
        }
    }

    @objc private func appleLoginButtonTapped() {
        // Analytics: 애플 로그인 클릭
        FirebaseAnalyticsService.shared.log(.appleLoginClick)

        loginView.isLoginInProgress = true
        Task { [weak self] in
            guard let self = self else { return }
            defer {
                Task { @MainActor [weak self] in
                    self?.loginView.isLoginInProgress = false
                }
            }
            do {
                let authToken = try await self.appleLoginUseCase.execute()
                await MainActor.run { [weak self] in
                    self?.coordinator?.handleLoginSuccess(authToken: authToken)
                }
            } catch {
                // 사용자 취소 시 에러 알림 표시하지 않음
                if self.isUserCancellationError(error) { return }
                await MainActor.run { [weak self] in
                    self?.showError(error)
                }
            }
        }
    }

    @objc private func guestLoginButtonTapped() {
        // Analytics: 게스트 모드 클릭
        FirebaseAnalyticsService.shared.log(.guestModeClick)

        loginView.isLoginInProgress = true
        Task { [weak self] in
            guard let self = self else { return }
            defer {
                Task { @MainActor [weak self] in
                    self?.loginView.isLoginInProgress = false
                }
            }
            do {
                let authToken = try await self.guestLoginUseCase.execute()
                await MainActor.run { [weak self] in
                    self?.coordinator?.handleLoginSuccess(authToken: authToken)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.showError(error)
                }
            }
        }
    }

    @objc private func debugSignupButtonTapped() {
        // 새 온보딩 플로우 테스트 (약관 동의부터 시작)
        coordinator?.showNewOnboardingFlow()
    }

    // MARK: - Helper

    private func isUserCancellationError(_ error: Error) -> Bool {
        // Apple 로그인 취소
        if let appleError = error as? AppleAuthService.AppleAuthError,
           case .userCancelled = appleError {
            return true
        }
        // Kakao 로그인 취소
        if let kakaoError = error as? KakaoAuthService.KakaoAuthError,
           case .userCancelled = kakaoError {
            return true
        }
        return false
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

#Preview {
    LoginViewController()
}
