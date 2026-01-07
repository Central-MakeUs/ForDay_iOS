//
//  BaseOnboardingViewController.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//


import UIKit
import SnapKit
import Then
import Combine

class BaseOnboardingViewController: UIViewController {
    
    // Properties
    let nextButton = UIButton()
    
    // Static으로 공유 (모든 VC가 같은 프로그래스바 사용)
    private static var sharedProgressBar: GradientProgressView?
    
    var cancellables = Set<AnyCancellable>()
    
    // Coordinator
    weak var coordinator: OnboardingCoordinator?
    
    // Layout Constants
    var horizontalPadding: CGFloat = 16
    var nextButtonVerticalPadding: CGFloat = 18
    var nextButtonBottomMargin: CGFloat = 16
    
    // Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupProgressBarIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // viewWillAppear에서는 아무것도 안 함 (이미 viewDidLoad에서 처리)
    }
    
    deinit {
        // 마지막 VC가 사라질 때 프로그래스바도 제거
        if navigationController?.viewControllers.isEmpty == true {
            BaseOnboardingViewController.sharedProgressBar?.removeFromSuperview()
            BaseOnboardingViewController.sharedProgressBar = nil
        }
    }
}

// Setup

extension BaseOnboardingViewController {
    private func style() {
        view.backgroundColor = .systemBackground
        
        // 내비게이션 바
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // 다음 버튼
        nextButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "다음"
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(
                top: nextButtonVerticalPadding,
                leading: 0,
                bottom: nextButtonVerticalPadding,
                trailing: 0
            )
            
            $0.configuration = config
            $0.isEnabled = false
            $0.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        }
    }
    
    private func layout() {
        view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(horizontalPadding)
            $0.trailing.equalToSuperview().offset(-horizontalPadding)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-nextButtonBottomMargin)
        }
    }
    
    private func setupProgressBarIfNeeded() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        // 이미 프로그래스바가 있으면 재사용
        if BaseOnboardingViewController.sharedProgressBar == nil {
            let progressBar = GradientProgressView()
            BaseOnboardingViewController.sharedProgressBar = progressBar
            
            navigationBar.addSubview(progressBar)
            
            progressBar.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.equalToSuperview().offset(16)
                $0.height.equalTo(8)
            }
        }
    }
}

// Public Methods

extension BaseOnboardingViewController {
    /// 네비게이션 타이틀 설정
    func setNavigationTitle(_ title: String) {
        navigationItem.title = title
    }
    
    /// 다음 버튼 활성화 상태 설정
    func setNextButtonEnabled(_ isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        
        var config = nextButton.configuration
        config?.baseBackgroundColor = isEnabled ? .action001 : .action003
        
        UIView.animate(withDuration: 0.2) {
            self.nextButton.configuration = config
        }
    }
    
    /// 프로그래스바 업데이트
    func updateProgress(_ progress: Float) {
        BaseOnboardingViewController.sharedProgressBar?.setProgress(progress, animated: true)
    }
}

// Actions

extension BaseOnboardingViewController {
    /// 뒤로가기 버튼 액션 (필요시 오버라이드)
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 다음 버튼 액션 (반드시 오버라이드 필요)
    @objc func nextButtonTapped() {
        fatalError("nextButtonTapped() must be overridden by subclass")
    }
}

#Preview {
    UINavigationController(rootViewController: HobbySelectionViewController(viewModel: .init()))
}
