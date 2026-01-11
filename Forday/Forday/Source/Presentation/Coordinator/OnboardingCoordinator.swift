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
        case .period: finish()
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
