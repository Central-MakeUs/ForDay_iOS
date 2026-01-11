//
//  LoginViewController.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import UIKit
import Combine

class LoginViewController: UIViewController {
    
    // Properties
    
    private let loginView = LoginView()
    private var cancellables = Set<AnyCancellable>()
    
    // UseCase
    private let kakaoLoginUseCase: KakaoLoginUseCase
    
    // Coordinator
    weak var coordinator: AuthCoordinator?
    
    // Initialization
    
    init(kakaoLoginUseCase: KakaoLoginUseCase = KakaoLoginUseCase(authRepository: AuthRepository())) {
        self.kakaoLoginUseCase = kakaoLoginUseCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
}

// Setup

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
    }
    
    @objc private func kakaoLoginButtonTapped() {
        Task {
            do {
                let isNewUser = try await kakaoLoginUseCase.execute()
                await MainActor.run {
                    coordinator?.handleLoginSuccess(isNewUser: isNewUser)
                }
            } catch {
                await MainActor.run {
                    showError(error)
                }
            }
        }
    }
    
    @objc private func appleLoginButtonTapped() {
        print("애플 로그인")
        // TODO: 애플 로그인 처리
    }
    
    @objc private func guestLoginButtonTapped() {
        print("게스트 로그인")
        // TODO: 게스트 로그인 처리
        // 임시: 신규 유저로 온보딩
        coordinator?.handleLoginSuccess(isNewUser: true)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "로그인 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

#Preview {
    LoginViewController()
}