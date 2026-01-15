//
//  HobbySelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//

import UIKit
import Combine

class HobbySelectionViewController: BaseOnboardingViewController {
    
    // Properties
    
    private let hobbyView = HobbySelectionView()
    private let viewModel: HobbySelectionViewModel
    
    // Initialization
    
    init(viewModel: HobbySelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func loadView() {
        view = hobbyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("취미 선택")
        setupCollectionView()
        setupActions()
        bind()
        
        // API 호출
        loadHobbies()
    }
    
    private func loadHobbies() {
        Task {
            await viewModel.fetchHobbies()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgress(0.2)
    }
    
    // Actions
    
    override func nextButtonTapped() {
        guard let selectedHobby = viewModel.selectedHobby else { return }
        
        // Coordinator에게 데이터 전달
        viewModel.onHobbySelected?(selectedHobby)
        
        // 다음 화면으로
        coordinator?.next(from: .hobby)
    }
    
    override func backButtonTapped() {
        coordinator?.dismissOnboarding()
    }
}

// Setup

extension HobbySelectionViewController {
    private func setupCollectionView() {
        hobbyView.collectionView.delegate = self
        hobbyView.collectionView.dataSource = self
    }
    
    private func setupActions() {
        hobbyView.customInputButton.addTarget(
            self,
            action: #selector(customInputButtonTapped),
            for: .touchUpInside
        )
    }
    
    private func bind() {
        // 취미 목록 변경 시 CollectionView 리로드
        viewModel.$hobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hobbyView.collectionView.reloadData()
                // CollectionView 높이 업데이트
                self?.hobbyView.updateCollectionViewHeight()
            }
            .store(in: &cancellables)
        
        // 선택된 취미 변경 시 CollectionView 업데이트
        viewModel.$selectedHobby
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hobbyView.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        // 다음 버튼 활성화 상태 변경
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.setNextButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)
        
        // 로딩 상태
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: 로딩 인디케이터 표시/숨김
                print(isLoading ? "로딩 중..." : "로딩 완료")
            }
            .store(in: &cancellables)
    }
    
    @objc private func customInputButtonTapped() {
        showCustomInputPopup()
    }
    
    private func showCustomInputPopup() {
        // TODO: HobbyInputPopupViewController 표시
        print("Show custom input popup")
    }
}

// UICollectionViewDataSource

extension HobbySelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.hobbies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HobbyCollectionViewCell.identifier,
            for: indexPath
        ) as? HobbyCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let hobby = viewModel.hobbies[indexPath.item]
        let isSelected = viewModel.isSelected(at: indexPath.item)
        cell.configure(with: hobby, isSelected: isSelected)
        
        return cell
    }
}

// UICollectionViewDelegate

extension HobbySelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectHobby(at: indexPath.item)
    }
}

// UICollectionViewDelegateFlowLayout

extension HobbySelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalPadding: CGFloat = 20
        let interItemSpacing: CGFloat = 12
        let availableWidth = collectionView.bounds.width - (horizontalPadding * 2) - interItemSpacing
        let itemWidth = availableWidth / 2
        let itemHeight: CGFloat = 160
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

#Preview {
    let nav = UINavigationController()
    let coordinator = OnboardingCoordinator(navigationController: nav)
    coordinator.start()
    return nav
}
