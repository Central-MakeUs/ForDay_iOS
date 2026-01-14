//
//  HomeViewController.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import UIKit
import Combine

class HomeViewController: UIViewController {
    
    // Properties
    
    private let homeView = HomeView()
    private let viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // Coordinator
    weak var coordinator: MainTabBarCoordinator?
    
    // Lifecycle
    
    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        bind()
        
        // 데이터 로드
        viewModel.loadOnboardingData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// Setup

extension HomeViewController {
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupActions() {
        // 취미 드롭다운 버튼
        homeView.hobbyDropdownButton.addTarget(
            self,
            action: #selector(hobbyDropdownTapped),
            for: .touchUpInside
        )
        
        // 알림 버튼
        homeView.notificationButton.addTarget(
            self,
            action: #selector(notificationTapped),
            for: .touchUpInside
        )
        
        // 나의 취미활동 쉐브론
        homeView.myActivityChevronButton.addTarget(
            self,
            action: #selector(myActivityChevronTapped),
            for: .touchUpInside
        )
        
        // 취미활동 추가하기 버튼
        homeView.addActivityButton.addTarget(
            self,
            action: #selector(addActivityButtonTapped),
            for: .touchUpInside
        )
    }
    
    private func bind() {
        // 온보딩 데이터 업데이트
        viewModel.$onboardingData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateUI(with: data)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with data: OnboardingData?) {
        guard let data = data,
              let hobbyCard = data.selectedHobbyCard else {
            return
        }
        
        // 취미 이름 업데이트
        var config = homeView.hobbyDropdownButton.configuration
        config?.title = hobbyCard.name
        homeView.hobbyDropdownButton.configuration = config
    }
}

// Actions

extension HomeViewController {
    @objc private func hobbyDropdownTapped() {
        print("취미 드롭다운 탭")
        // TODO: 취미 목록 바텀시트
    }
    
    @objc private func notificationTapped() {
        print("알림 탭")
        // TODO: 알림 화면
    }
    
    @objc private func myActivityChevronTapped() {
        print("나의 취미활동 쉐브론 탭")
        // TODO: 활동 리스트 화면
    }
    
    @objc private func addActivityButtonTapped() {
        print("취미활동 추가하기 탭")
        showAIRecommendationModal()
    }

    private func showAIRecommendationModal() {
        let containerVC = AIRecommendationContainerViewController(viewModel: viewModel)
        containerVC.modalPresentationStyle = .pageSheet
        
        if let sheet = containerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(containerVC, animated: true)
    }
}

#Preview {
    let nav = UINavigationController()
    let vc = HomeViewController()
    nav.setViewControllers([vc], animated: false)
    return nav
}
