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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 네비게이션 바 숨김 (progress bar 제거)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 그라디언트 즉시 표시를 위해 셀 리로드
        completeView.collectionView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 다음 화면을 위해 네비게이션 바 다시 보이기
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// Setup

extension OnboardingCompleteViewController {
    private func setupNavigationBar() {
        // 뒤로가기 버튼 숨기기
        navigationItem.hidesBackButton = true
        // Swipe back gesture 비활성화
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
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
