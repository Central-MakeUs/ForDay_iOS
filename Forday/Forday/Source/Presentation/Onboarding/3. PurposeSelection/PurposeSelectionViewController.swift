//
//  PurposeSelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import UIKit
import Combine

class PurposeSelectionViewController: BaseOnboardingViewController {

    // Properties

    private let purposeView = PurposeSelectionView()
    private let viewModel: PurposeSelectionViewModel

    // Initialization

    init(viewModel: PurposeSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Lifecycle

    override func loadView() {
        view = purposeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("취미 목적")
        setupCollectionView()
        setupActions()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgress(0.6)  // 3/5 = 60%
        setupHobbyCard()
    }

    // Actions

    override func nextButtonTapped() {
        guard let selectedPurpose = viewModel.selectedPurpose else { return }
        guard !isTransitioning else { return }
        startTransition()
        viewModel.onPurposeSelected?(selectedPurpose.title)
        coordinator?.next(from: .purpose)
    }

    override func backButtonTapped() {
        // 커스텀 목적도 coordinator에게 전달
        if let customText = viewModel.customPurposeText {
            viewModel.onPurposeSelected?(customText)
        }
        navigationController?.popViewController(animated: true)
    }
}

// Setup

extension PurposeSelectionViewController {
    private func setupHobbyCard() {
        guard let onboardingData = coordinator?.getOnboardingData(),
              let hobbyCard = onboardingData.selectedHobbyCard else {
            return
        }

        // 아이콘 이미지 설정
        let icon = hobbyCard.imageAsset.icon

        // 시간 정보 설정
        let time = onboardingData.timeMinutes > 0 ? "\(onboardingData.timeMinutes)분" : nil

        purposeView.configureHobbyCard(icon: icon, title: hobbyCard.name, time: time)
    }

    private func setupCollectionView() {
        purposeView.collectionView.delegate = self
        purposeView.collectionView.dataSource = self
    }

    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(customInputButtonTapped))
        purposeView.customInputButtonView.addGestureRecognizer(tapGesture)
    }

    private func bind() {
        // 목적 데이터 로드 시 CollectionView 높이 업데이트
        viewModel.$purposes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.purposeView.collectionView.reloadData()
                self?.purposeView.updateCollectionViewHeight()
            }
            .store(in: &cancellables)

        // 선택된 목적 변경 시 CollectionView 업데이트
        viewModel.$selectedPurpose
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.purposeView.collectionView.reloadData()
            }
            .store(in: &cancellables)

        // 다음 버튼 활성화 상태 바인딩
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.setNextButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)
    }

    @objc private func customInputButtonTapped() {
        showCustomInputPopup()
    }

    private func showCustomInputPopup() {
        guard !isTransitioning else { return }

        let popup = TextInputPopupViewController(title: "목적 입력", placeholder: "목적을 입력해 주세요.")
        popup.initialText = viewModel.customPurposeText
        popup.onSubmit = { [weak self] purposeText in
            guard let self else { return }
            self.viewModel.setCustomPurpose(purposeText)
            self.purposeView.updateCustomInputButton(purposeName: purposeText)
            self.purposeView.selectedHobbyCard.setSelected(true)
            self.purposeView.collectionView.reloadData()
            // 입력한 목적을 HobbyCard에 실시간 표시
            self.updateHobbyCardInfo(purpose: purposeText)
        }
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: true)
    }
}

// UICollectionViewDataSource

extension PurposeSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.purposes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PurposeOptionCell.identifier,
            for: indexPath
        ) as? PurposeOptionCell else {
            return UICollectionViewCell()
        }

        let purpose = viewModel.purposes[indexPath.item]
        let isSelected = viewModel.isSelected(at: indexPath.item)
        cell.configure(with: purpose, isSelected: isSelected)

        return cell
    }
}

// UICollectionViewDelegate

extension PurposeSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectPurpose(at: indexPath.item)
        purposeView.selectedHobbyCard.setSelected(true)
        purposeView.resetCustomInputButton()

        // 선택한 목적을 HobbyCard에 실시간 표시
        let purpose = viewModel.purposes[indexPath.item]
        updateHobbyCardInfo(purpose: purpose.title)
    }

    private func updateHobbyCardInfo(purpose: String) {
        let onboardingData = coordinator?.getOnboardingData()
        let time = onboardingData?.timeMinutes ?? 0 > 0 ? "\(onboardingData!.timeMinutes)분" : nil
        purposeView.selectedHobbyCard.updateInfo(time: time, purpose: purpose)
    }
}

// UICollectionViewDelegateFlowLayout

extension PurposeSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interItemSpacing: CGFloat = 8
        let availableWidth = collectionView.bounds.width - interItemSpacing
        let itemWidth = availableWidth / 2
        let itemHeight: CGFloat = itemWidth

        return CGSize(width: itemWidth, height: itemHeight)
    }
}

#Preview {
    let nav = UINavigationController()
    let coordinator = OnboardingCoordinator(navigationController: nav)
    coordinator.show(.purpose)
    return nav
}
