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
    private static var sharedProgressContainer: UIView?
    private static var sharedProgressBar: GradientProgressView?

    /// 화면 전환 중 여부 (중복 탭 방지)
    private(set) var isTransitioning: Bool = false

    /// 자동 진행 작업 (중복 탭 시 취소용)
    var autoAdvanceWorkItem: DispatchWorkItem?

    var cancellables = Set<AnyCancellable>()

    // Coordinator
    weak var coordinator: OnboardingCoordinator?

    /// 프로그래스바 스킵 여부 (수정 모드용)
    var shouldSkipProgressBar: Bool = false

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
        // 화면이 다시 나타날 때 전환 상태 초기화 (뒤로가기 시 재활성화)
        resetTransition()
    }
    
    deinit {
        // 마지막 VC가 사라질 때 프로그래스바도 제거
        if navigationController?.viewControllers.isEmpty == true {
            BaseOnboardingViewController.sharedProgressContainer?.removeFromSuperview()
            BaseOnboardingViewController.sharedProgressContainer = nil
            BaseOnboardingViewController.sharedProgressBar = nil
        }
    }
}

// Setup

extension BaseOnboardingViewController {
    private func style() {
        view.backgroundColor = .neutral50

        // 내비게이션 바 커스텀
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .neutral50
        appearance.shadowColor = nil
        appearance.titleTextAttributes = [.foregroundColor: UIColor.neutral900]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = false

        // 뒤로가기 버튼
        let backButton = UIBarButtonItem(
            image: .Icon.chevronLeft,
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .neutral900
        navigationItem.leftBarButtonItem = backButton

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
        // 수정 모드에서는 프로그래스바 생성 스킵
        guard !shouldSkipProgressBar else { return }
        guard let navigationBar = navigationController?.navigationBar else { return }

        // 이미 프로그래스바가 있으면 재사용
        if BaseOnboardingViewController.sharedProgressBar == nil {
            let container = UIView()
            container.backgroundColor = .neutral50
            container.isUserInteractionEnabled = false

            let progressBar = GradientProgressView()
            BaseOnboardingViewController.sharedProgressContainer = container
            BaseOnboardingViewController.sharedProgressBar = progressBar

            navigationBar.addSubview(container)
            container.addSubview(progressBar)

            container.snp.makeConstraints {
                $0.top.equalTo(navigationBar.snp.bottom)
                $0.leading.trailing.equalToSuperview()
            }

            progressBar.snp.makeConstraints {
                $0.top.equalToSuperview().offset(8)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.height.equalTo(8)
                $0.bottom.equalToSuperview().offset(-16)
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

    /// 다음 버튼 숨기기 (자동 진행 화면용)
    func hideNextButton() {
        nextButton.isHidden = true
    }

    /// 프로그래스바 숨기기 (닉네임 설정 화면용)
    func hideProgressBar() {
        BaseOnboardingViewController.sharedProgressContainer?.isHidden = true
    }

    /// 프로그래스바 초기화 (새로운 온보딩 시작 시)
    static func resetProgressBar() {
        sharedProgressContainer?.removeFromSuperview()
        sharedProgressContainer = nil
        sharedProgressBar = nil
        print("✅ 프로그래스바 초기화 완료")
    }

    /// 화면 전환 시작 (중복 탭 방지)
    func startTransition() {
        isTransitioning = true
        view.isUserInteractionEnabled = false
    }

    /// 화면 전환 상태 초기화
    func resetTransition() {
        autoAdvanceWorkItem?.cancel()
        autoAdvanceWorkItem = nil
        isTransitioning = false
        view.isUserInteractionEnabled = true
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

#if DEBUG
#Preview {
    UINavigationController(rootViewController: HobbySelectionViewController(viewModel: .init()))
}
#endif
