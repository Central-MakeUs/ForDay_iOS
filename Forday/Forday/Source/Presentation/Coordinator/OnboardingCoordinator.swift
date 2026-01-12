//
//  OnboardingCoordinator.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import UIKit

class OnboardingCoordinator: Coordinator {
    
    // Properties
    
    let navigationController: UINavigationController
    weak var parentCoordinator: AuthCoordinator?  // 추가!
    
    // Initialization
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // Coordinator
    
    func start() {
        show(.hobby)
    }
    
    // Navigation
    
    func show(_ step: OnboardingStep) {
        let vc: UIViewController
        
        switch step {
        case .hobby:
            let viewModel = HobbySelectionViewModel()
            vc = HobbySelectionViewController(viewModel: viewModel)
            
        case .time:
            let viewModel = TimeSelectionViewModel()
            vc = TimeSelectionViewController(viewModel: viewModel)
            
        case .purpose:
            let viewModel = PurposeSelectionViewModel()
            vc = PurposeSelectionViewController(viewModel: viewModel)
            
        case .frequency:
            let viewModel = FrequencySelectionViewModel()
            vc = FrequencySelectionViewController(viewModel: viewModel)
            
        case .period:
            let viewModel = PeriodSelectionViewModel()
            vc = PeriodSelectionViewController(viewModel: viewModel)
            
        case .complete:
            vc = OnboardingCompleteViewController()
            (vc as? OnboardingCompleteViewController)?.coordinator = self
            
            
        }
        
        
        
        // Coordinator 주입
        if let baseVC = vc as? BaseOnboardingViewController {
            baseVC.coordinator = self
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func next(from currentStep: OnboardingStep) {
        switch currentStep {
        case .hobby: show(.time)
        case .time: show(.purpose)
        case .purpose: show(.frequency)
        case .frequency: show(.period)
        case .period:
            show(.complete)
            // Complete 화면이 push 완료된 후 스택 정리
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.removeOnboardingStepsFromStack()
            }
        case .complete:
            break
        }
    }
    
    // 닉네임 설정 화면으로
    func showNicknameSetup() {
        let vc = NicknameViewController()
        vc.coordinator = self
        
        // Complete 화면 제거하고 Nickname만 남기기
        var viewControllers = navigationController.viewControllers
        if let completeIndex = viewControllers.firstIndex(where: { $0 is OnboardingCompleteViewController }) {
            viewControllers.remove(at: completeIndex)
        }
        viewControllers.append(vc)
        navigationController.setViewControllers(viewControllers, animated: true)
    }
    
    // 닉네임 설정 완료 후 홈으로
    func completeNicknameSetup() {
        navigationController.dismiss(animated: true) {
            self.parentCoordinator?.completeOnboarding()
        }
    }
    
    // 온보딩 단계들을 스택에서 제거
    private func removeOnboardingStepsFromStack() {
        if let completeVC = navigationController.viewControllers.last as? OnboardingCompleteViewController {
            // 애니메이션 없이 조용히 스택 정리
            navigationController.setViewControllers([completeVC], animated: false)
        }
    }
    
    func finish() {
        // 온보딩 완료 후 홈으로
        navigationController.dismiss(animated: true) {
            self.parentCoordinator?.completeOnboarding()
        }
    }
    
    func dismissOnboarding() {
        navigationController.dismiss(animated: true)
    }
}
