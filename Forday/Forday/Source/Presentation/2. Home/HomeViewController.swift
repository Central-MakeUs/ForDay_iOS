//
//  HomeViewController.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import UIKit
import Combine
import SnapKit

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
        
        present(containerVC, animated: true) {
            // 시트 표시 후 토스트를 window에 추가
            self.showToastAboveSheet()
        }
        
        // 토스트 제거 클로저 전달
        containerVC.onDismissToast = { [weak self] in
            self?.hideToast()
        }
    }

    private func showToastAboveSheet() {
        // window 가져오기
        guard let window = view.window else { return }
        
        // 기존 토스트 제거
        window.subviews.filter { $0 is ToastView }.forEach { $0.removeFromSuperview() }
        
        // 새 토스트 생성
        let toast = ToastView(message: "포데이 AI가 알맞은 취미활동을 추천해드려요")
        toast.tag = 9999 // 나중에 찾기 위한 태그
        
        // window에 추가
        window.addSubview(toast)
        
        // presentedViewController의 view를 기준으로 위치 설정
        if let sheetView = presentedViewController?.view {
            toast.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(26)
                $0.bottom.equalTo(sheetView.snp.top).offset(-20)  // 시트 top으로부터 20 위
            }
        } 
        
        // 페이드 인
        toast.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        }
    }

    func hideToast() {
        guard let window = view.window else { return }
        
        window.subviews.filter { $0.tag == 9999 }.forEach {
            ($0 as? ToastView)?.hide()
        }
    }
}

#Preview {
    let nav = UINavigationController()
    let vc = HomeViewController()
    nav.setViewControllers([vc], animated: false)
    return nav
}
