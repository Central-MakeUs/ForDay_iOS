//
//  OnboardingCompleteViewController.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import UIKit

class OnboardingCompleteViewController: UIViewController {
    
    // Properties
    
    private let completeView = OnboardingCompleteView()
    
    // Coordinator
    weak var coordinator: OnboardingCoordinator?
    
    // Lifecycle
    
    override func loadView() {
        view = completeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
    }
}

// Setup

extension OnboardingCompleteViewController {
    private func setupNavigationBar() {
        // 네비게이션 바 숨김
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupActions() {
        completeView.startButton.addTarget(
            self,
            action: #selector(startButtonTapped),
            for: .touchUpInside
        )
    }
    
    @objc private func startButtonTapped() {
        coordinator?.showNicknameSetup()
    }
}

#Preview {
    let nav = UINavigationController()
    let vc = OnboardingCompleteViewController()
    nav.setViewControllers([vc], animated: false)
    return nav
}