//
//  TimeSelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import UIKit
import Combine

class TimeSelectionViewController: BaseOnboardingViewController {
    
    // Properties
    
    private let timeView = TimeSelectionView()
    private let viewModel: TimeSelectionViewModel
    
    // Initialization
    
    init(viewModel: TimeSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func loadView() {
        view = timeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("취미 시간")
        setupSlider()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgress(0.4)
    }
    
    // Actions
    
    override func nextButtonTapped() {
        print("Selected time: \(viewModel.selectedTime ?? "None")")
        coordinator?.next(from: .time)
    }
}

// Setup

extension TimeSelectionViewController {
    private func setupSlider() {
        timeView.timeSlider.onValueChanged = { [weak self] time in
            self?.viewModel.selectTime(time)
        }
    }
    
    private func bind() {
        // 다음 버튼 활성화 상태 변경
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.setNextButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)
    }
}

#Preview {
    let nav = UINavigationController()
    let coordinator = OnboardingCoordinator(navigationController: nav)
    coordinator.show(.time)
    return nav
}
