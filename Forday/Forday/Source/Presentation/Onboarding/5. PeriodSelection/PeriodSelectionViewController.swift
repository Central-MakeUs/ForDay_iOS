//
//  PeriodSelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//


import UIKit
import Combine

class PeriodSelectionViewController: BaseOnboardingViewController {

    // MARK: - Properties

    private let periodView = PeriodSelectionView()
    let viewModel: PeriodSelectionViewModel

    // Edit Mode Properties
    var isEditMode: Bool = false
    var hobbyId: Int?
    var onChangeComplete: (() -> Void)?

    private let updateGoalDaysUseCase = UpdateGoalDaysUseCase()

    // MARK: - Initialization

    init(viewModel: PeriodSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = periodView
    }

    override func viewDidLoad() {
        // 수정 모드일 때 프로그래스바 생성 스킵
        shouldSkipProgressBar = isEditMode
        super.viewDidLoad()
        setNavigationTitle("취미 정보")
        // Edit Mode에서는 다음 버튼 숨김 (변경하기 버튼 사용)
        if isEditMode {
            hideNextButton()
        }
        setupCollectionView()
        setupEditMode()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isEditMode {
            updateProgress(1.0)  // 5/5 = 100%
        }
        setupHobbyCard()
    }

    private func setupEditMode() {
        guard isEditMode else { return }

        // Enable edit mode on view
        periodView.setEditMode(true)

        // Hide base onboarding navigation
        hideProgressBar()
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Setup callbacks
        periodView.onCloseButtonTapped = { [weak self] in
            self?.dismiss(animated: true)
        }

        periodView.onChangeButtonTapped = { [weak self] in
            self?.handleChangeButtonTapped()
        }
    }

    // MARK: - Edit Mode Configuration

    func configureForEditMode(hobbyId: Int, icon: UIImage?, title: String, time: String?, frequency: String?, purpose: String?) {
        self.isEditMode = true
        self.hobbyId = hobbyId
        periodView.configureHobbyCard(icon: icon, title: title, time: time, frequency: frequency, purpose: purpose)
    }

    // MARK: - Actions

    override func nextButtonTapped() {
        guard viewModel.selectedPeriod != nil else { return }
        guard let onboardingCoordinator = coordinator as? OnboardingCoordinator else { return }
        guard !isTransitioning else { return }

        startTransition()

        let onboardingData = onboardingCoordinator.getOnboardingData()

        Task { @MainActor in
            await viewModel.createHobby(with: onboardingData)
        }
    }

    private func handleChangeButtonTapped() {
        guard let hobbyId = hobbyId,
              let selectedPeriod = viewModel.selectedPeriod else { return }

        // Convert PeriodType to isDurationSet
        let isDurationSet: Bool
        switch selectedPeriod.type {
        case .flexible:
            isDurationSet = false
        case .fixed:
            isDurationSet = true
        }

        Task {
            do {
                _ = try await updateGoalDaysUseCase.execute(hobbyId: hobbyId, isDurationSet: isDurationSet)

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

extension PeriodSelectionViewController {
    private func setupHobbyCard() {
        guard let onboardingData = coordinator?.getOnboardingData(),
              let hobbyCard = onboardingData.selectedHobbyCard else {
            return
        }

        // 아이콘 이미지 설정
        let icon = hobbyCard.imageAsset.icon

        // 시간 정보 설정
        let time = onboardingData.timeMinutes > 0 ? "\(onboardingData.timeMinutes)분" : nil

        // 횟수 정보 설정
        let frequency = onboardingData.executionCount > 0 ? "주 \(onboardingData.executionCount)회" : nil

        // 목적 정보 설정 (빈 문자열이 아닐 때만)
        let purpose = !onboardingData.purpose.isEmpty ? onboardingData.purpose : nil

        periodView.configureHobbyCard(
            icon: icon,
            title: hobbyCard.name,
            time: time,
            frequency: frequency,
            purpose: purpose
        )
    }

    private func setupCollectionView() {
        periodView.collectionView.delegate = self
        periodView.collectionView.dataSource = self
    }

    private func bind() {
        // 취미 생성 성공 시 처리
        viewModel.onHobbyCreated = { [weak self] hobbyId in
            guard let self else { return }
            self.resetTransition()
            self.coordinator?.next(from: .period)
        }

        // 선택된 기간 변경 시 CollectionView 업데이트
        viewModel.$selectedPeriod
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.periodView.collectionView.reloadData()
            }
            .store(in: &cancellables)

        // 다음 버튼 활성화 상태 바인딩 (온보딩 모드에서만)
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                guard let self, !self.isEditMode else { return }
                self.setNextButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)

        // 로딩 상태 변경
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: 로딩 인디케이터 표시
                if isLoading {
                    print("⏳ 취미 생성 중...")
                }
            }
            .store(in: &cancellables)

        // 에러 메시지 표시
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    print("❌ 에러: \(error)")
                    // 에러 시 화면 전환 상태 초기화
                    self?.resetTransition()
                    // TODO: 에러 얼럿 표시
                }
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
        periodView.selectedHobbyCard.setSelected(true)

        // 선택한 기간을 HobbyCard에 실시간 표시
        let period = viewModel.periods[indexPath.item]
        let periodText = period.type == .fixed ? "66일" : "자율모드"
        updateHobbyCardInfo(period: periodText)
    }

    private func updateHobbyCardInfo(period: String) {
        let onboardingData = coordinator?.getOnboardingData()
        let time = onboardingData?.timeMinutes ?? 0 > 0 ? "\(onboardingData!.timeMinutes)분" : nil
        let frequency = onboardingData?.executionCount ?? 0 > 0 ? "주 \(onboardingData!.executionCount)회" : nil
        let purpose = onboardingData?.purpose.isEmpty == false ? onboardingData?.purpose : nil
        periodView.selectedHobbyCard.updateInfo(time: time, frequency: frequency, purpose: purpose, period: period)
    }
}

// UICollectionViewDelegateFlowLayout

extension PeriodSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 정사각형 셀: (화면 너비 - 20 - 8 - 20) / 2
        let spacing: CGFloat = 8
        let horizontalPadding: CGFloat = 20 * 2  // leading + trailing
        let cellSize = (collectionView.bounds.width - spacing) / 2

        return CGSize(width: cellSize, height: cellSize)
    }
}

#Preview {
    let nav = UINavigationController()
    let coordinator = OnboardingCoordinator(navigationController: nav)
    coordinator.show(.period)
    return nav
}
