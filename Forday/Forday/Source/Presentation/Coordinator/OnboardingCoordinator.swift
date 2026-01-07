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
            let viewModel = FrequencySelectionViewModel()  // 추가!
            vc = FrequencySelectionViewController(viewModel: viewModel)
            
        case .goalDate:
            // TODO: 나중에 구현
            vc = UIViewController()
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
        case .frequency: show(.goalDate)
        case .goalDate: finish()
        }
    }
    
    func finish() {
        // TODO: 온보딩 완료 후 MainTabBar로 이동
        navigationController.dismiss(animated: true)
    }
    
    func dismissOnboarding() {
        navigationController.dismiss(animated: true)
    }
}
