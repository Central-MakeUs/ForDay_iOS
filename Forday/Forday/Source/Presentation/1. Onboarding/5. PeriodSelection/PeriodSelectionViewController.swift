//
//  PeriodSelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//


import UIKit
import Combine

class PeriodSelectionViewController: BaseOnboardingViewController {
    
    // Properties
    
    private let periodView = PeriodSelectionView()
    private let viewModel: PeriodSelectionViewModel
    
    // Initialization
    
    init(viewModel: PeriodSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func loadView() {
        view = periodView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("여정일")
        setupCollectionView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgress(1.0)  // 5/5 = 100%
    }
    
    // Actions
    
    override func nextButtonTapped() {
        print("Selected period: \(viewModel.selectedPeriod?.title ?? "None")")
        coordinator?.finish()
    }
}

// Setup

extension PeriodSelectionViewController {
    private func setupCollectionView() {
        periodView.collectionView.delegate = self
        periodView.collectionView.dataSource = self
    }
    
    private func bind() {
        // 선택된 기간 변경 시 CollectionView 업데이트
        viewModel.$selectedPeriod
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.periodView.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        // 다음 버튼 활성화 상태 변경
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.setNextButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)
    }
}

// UICollectionViewDataSource

extension PeriodSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.periods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PeriodOptionCell.identifier,
            for: indexPath
        ) as? PeriodOptionCell else {
            return UICollectionViewCell()
        }
        
        let period = viewModel.periods[indexPath.item]
        let isSelected = viewModel.isSelected(at: indexPath.item)
        cell.configure(with: period, isSelected: isSelected)
        
        return cell
    }
}

// UICollectionViewDelegate

extension PeriodSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectPeriod(at: indexPath.item)
    }
}

// UICollectionViewDelegateFlowLayout

extension PeriodSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 84
        
        return CGSize(width: width, height: height)
    }
}

#Preview {
    let nav = UINavigationController()
    let coordinator = OnboardingCoordinator(navigationController: nav)
    coordinator.show(.period)
    return nav
}
