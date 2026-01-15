//
//  AIRecommendationContainerViewController.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import Combine
import SnapKit

class AIRecommendationContainerViewController: UIViewController {
    
    // Properties
    
    private var currentView: UIView?
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var onDismissToast: (() -> Void)?
    
    private var currentStep: AIRecommendationStep = .intro {
        didSet {
            updateModalSettings()
        }
    }
    
    // Views
    private let introView = AIRecommendationIntroView()
    private let loadingView = AIRecommendationLoadingView()
    private var selectionView: AIActivitySelectionView?
    
    // Initialization
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupActions()
        bind()
        showIntro()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 시트가 사라질 때 토스트도 제거
        onDismissToast?()
    }
}

// Setup

extension AIRecommendationContainerViewController {
    private func setupActions() {
        // Intro View
        introView.onAIRecommendTapped = { [weak self] in
            self?.startAIRecommendation()
        }
        
        // Loading View는 액션 없음
    }
    
    private func bind() {
        // AI 추천 결과
        viewModel.$aiRecommendationResult
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] result in
                self?.showSelection(with: result)
            }
            .store(in: &cancellables)
    }
}

// Navigation

extension AIRecommendationContainerViewController {
    
    private func showIntro() {
        currentStep = .intro
        transitionToView(introView)
    }
    
    private func startAIRecommendation() {
        // 토스트 제거
        onDismissToast?()
        
        currentStep = .loading
        transitionToView(loadingView)
        
        // API 호출
        Task {
            do {
                try await viewModel.fetchAIRecommendations()
            } catch {
                await MainActor.run {
                    self.showError(error)
                    self.showIntro()
                }
            }
        }
    }
    
    private func showSelection(with result: AIRecommendationResult) {
        currentStep = .selection
        
        let selectionView = AIActivitySelectionView(result: result)
        selectionView.onActivitySelected = { [weak self] activity in
            print("선택된 활동: \(activity.content)")
            self?.dismiss(animated: true)
        }
        
        selectionView.onRefreshTapped = { [weak self] in
            self?.startAIRecommendation() // 재요청
        }
        
        self.selectionView = selectionView
        transitionToView(selectionView)
    }
    
    private func transitionToView(_ newView: UIView) {
        // 기존 View 제거
        currentView?.removeFromSuperview()
        
        // 새 View 추가
        view.addSubview(newView)
        newView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        currentView = newView
    }
    
    private func updateModalSettings() {
        switch currentStep {
        case .intro:
            isModalInPresentation = false
            if let sheet = sheetPresentationController {
                sheet.detents = [
                    .custom(identifier: .init("intro")) { _ in 236 }
                ]
                sheet.preferredCornerRadius = 2
                sheet.prefersGrabberVisible = true
            }
            
        case .loading:
            isModalInPresentation = true
            if let sheet = sheetPresentationController {
                sheet.detents = [
                    .custom(identifier: .init("loading")) { _ in 236 }
                ]
                sheet.preferredCornerRadius = 20
                sheet.prefersGrabberVisible = false
            }
            
        case .selection:
            isModalInPresentation = false
            if let sheet = sheetPresentationController {
                sheet.detents = [
                    .custom(identifier: .init("selection")) { context in
                        
                        return context.maximumDetentValue * 0.8 }
                ]
                sheet.preferredCornerRadius = 20
                sheet.prefersGrabberVisible = true
                sheet.largestUndimmedDetentIdentifier = .large
            }
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
