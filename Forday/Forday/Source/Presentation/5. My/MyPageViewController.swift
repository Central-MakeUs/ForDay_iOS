//
//  MyPageViewController.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import SnapKit
import Then

class MyPageViewController: UIViewController {
    
    // Properties
    
    private let logoutButton = UIButton()
    
    // Coordinator
    weak var coordinator: MainTabBarCoordinator?
    
    // Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupActions()
    }
}

// Setup

extension MyPageViewController {
    private func style() {
        view.backgroundColor = .systemBackground
        title = "마이"
        
        logoutButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "로그아웃"
            config.baseBackgroundColor = .systemRed
            config.baseForegroundColor = .white
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
            
            $0.configuration = config
        }
    }
    
    private func layout() {
        view.addSubview(logoutButton)
        
        logoutButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func setupActions() {
        logoutButton.addTarget(
            self,
            action: #selector(logoutButtonTapped),
            for: .touchUpInside
        )
    }
}

// Actions

extension MyPageViewController {
    @objc private func logoutButtonTapped() {
        showLogoutAlert()
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "정말 로그아웃 하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        do {
            // 토큰 삭제
            try TokenStorage.shared.deleteAllTokens()
            
            // 온보딩 데이터 삭제 (선택사항)
            try? OnboardingDataStorage.shared.delete()
            
            print("✅ 로그아웃 완료")
            
            // AppCoordinator에게 로그아웃 알림
            coordinator?.parentCoordinator?.logout()
            
        } catch {
            print("❌ 로그아웃 실패: \(error)")
            showError(error)
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
