//
//  FrequencySelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import UIKit
import Combine

class FrequencySelectionViewController: BaseOnboardingViewController {
    
    // Properties
    
    private let frequencyView = FrequencySelectionView()
    private let viewModel: FrequencySelectionViewModel
    
    // Initialization
    
    init(viewModel: FrequencySelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func loadView() {
        view = frequencyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("실행 횟수")
        setupCollectionView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgress(0.8)  // 4/5 = 80%
    }
    
    // Actions
    
    override func nextButtonTapped() {
        guard let selectedFrequency = viewModel.selectedFrequency else { return }
        
        // Coordinator에게 데이터 전달
        viewModel.onFrequencySelected?(selectedFrequency.count)
        
        // 다음 화면으로
        coordinator?.next(from: .frequency)
    }
}

// Setup

extension FrequencySelectionViewController {
    private func setupCollectionView() {
        frequencyView.collectionView.delegate = self
        frequencyView.collectionView.dataSource = self
    }
    
    private func bind() {
        // 선택된 횟수 변경 시 CollectionView 업데이트
        viewModel.$selectedFrequency
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.frequencyView.collectionView.reloadData()
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

extension FrequencySelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.frequencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FrequencyButtonCell.identifier,
            for: indexPath
        ) as? FrequencyButtonCell else {
            return UICollectionViewCell()
        }
        
        let frequency = viewModel.frequencies[indexPath.item]
        let isSelected = viewModel.isSelected(at: indexPath.item)
        cell.configure(count: frequency.count, isSelected: isSelected)
        
        return cell
    }
}

// UICollectionViewDelegate

extension FrequencySelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectFrequency(at: indexPath.item)
    }
}

// UICollectionViewDelegateFlowLayout

extension FrequencySelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width: CGFloat = collectionView.bounds.width / CGFloat(viewModel.frequencies.count)
        let height: CGFloat = 40
        return CGSize(width: width, height: height)
    }
}

#Preview {
    let nav = UINavigationController()
    let coordinator = OnboardingCoordinator(navigationController: nav)
    coordinator.show(.frequency)
    return nav
}
