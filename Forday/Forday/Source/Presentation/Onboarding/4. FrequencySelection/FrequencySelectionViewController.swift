//
//  FrequencySelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import UIKit
import Combine

class FrequencySelectionViewController: BaseOnboardingViewController {

    // MARK: - Properties

    private let frequencyView = FrequencySelectionView()
    let viewModel: FrequencySelectionViewModel

    // Edit Mode Properties
    var isEditMode: Bool = false
    var hobbyId: Int?
    var onChangeComplete: (() -> Void)?

    private let updateExecutionCountUseCase = UpdateExecutionCountUseCase()

    // MARK: - Initialization

    init(viewModel: FrequencySelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = frequencyView
    }

    override func viewDidLoad() {
        // 수정 모드일 때 프로그래스바 생성 스킵
        shouldSkipProgressBar = isEditMode
        super.viewDidLoad()
        setNavigationTitle("취미 정보")
        hideNextButton()
        setupCollectionView()
        setupEditMode()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isEditMode {
            updateProgress(0.8)  // 4/5 = 80%
        }
        setupHobbyCard()
    }

    private func setupEditMode() {
        guard isEditMode else { return }

        // Enable edit mode on view
        frequencyView.setEditMode(true)

        // Hide base onboarding navigation
        hideProgressBar()
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Setup callbacks
        frequencyView.onCloseButtonTapped = { [weak self] in
            self?.dismiss(animated: true)
        }

        frequencyView.onChangeButtonTapped = { [weak self] in
            self?.handleChangeButtonTapped()
        }
    }

    // MARK: - Edit Mode Configuration

    func configureForEditMode(hobbyId: Int, icon: UIImage?, title: String, time: String?, purpose: String?) {
        self.isEditMode = true
        self.hobbyId = hobbyId
        frequencyView.configureHobbyCard(icon: icon, title: title, time: time, purpose: purpose)
    }

    // MARK: - Actions

    private func autoAdvance() {
        // Skip auto-advance in edit mode
        guard !isEditMode else { return }
        guard let selectedFrequency = viewModel.selectedFrequency else { return }
        guard !isTransitioning else { return }

        // 이전 자동 진행 작업 취소
        autoAdvanceWorkItem?.cancel()

        // Coordinator에게 데이터 전달
        viewModel.onFrequencySelected?(selectedFrequency.count)

        // 화면 전환 시작
        startTransition()

        // 다음 화면으로 (약간의 딜레이 후)
        let workItem = DispatchWorkItem { [weak self] in
            self?.coordinator?.next(from: .frequency)
        }
        autoAdvanceWorkItem = workItem

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
    }

    private func handleChangeButtonTapped() {
        guard let hobbyId = hobbyId,
              let selectedFrequency = viewModel.selectedFrequency else { return }

        Task {
            do {
                _ = try await updateExecutionCountUseCase.execute(hobbyId: hobbyId, executionCount: selectedFrequency.count)

                await MainActor.run {
                    self.dismiss(animated: true) {
                        self.onChangeComplete?()
                    }
                }
            } catch let appError as AppError {
                await MainActor.run {
                    self.showError(appError.userMessage)
                }
            } catch {
                await MainActor.run {
                    self.showError(error.localizedDescription)
                }
            }
        }
    }

    private func showError(_ message: String) {
        ToastView.showError(message: message)
    }
}

// Setup

extension FrequencySelectionViewController {
    private func setupHobbyCard() {
        guard let onboardingData = coordinator?.getOnboardingData(),
              let hobbyCard = onboardingData.selectedHobbyCard else {
            return
        }

        // 아이콘 이미지 설정
        let icon = hobbyCard.imageAsset.icon

        // 시간 정보 설정
        let time = onboardingData.timeMinutes > 0 ? "\(onboardingData.timeMinutes)분" : nil

        // 목적 정보 설정
        let purpose = !onboardingData.purpose.isEmpty ? onboardingData.purpose : nil

        frequencyView.configureHobbyCard(icon: icon, title: hobbyCard.name, time: time, purpose: purpose)
    }

    private func setupCollectionView() {
        frequencyView.collectionView.delegate = self
        frequencyView.collectionView.dataSource = self
    }

    private func bind() {
        // 선택된 횟수 변경 시 CollectionView 업데이트 및 자동 진행
        viewModel.$selectedFrequency
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.frequencyView.collectionView.reloadData()
                self?.autoAdvance()
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
        frequencyView.selectedHobbyCard.setSelected(true)
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
