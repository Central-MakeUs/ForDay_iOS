//
//  TimeSelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import UIKit
import Combine

class TimeSelectionViewController: BaseOnboardingViewController {

    // MARK: - Properties

    private let timeView = TimeSelectionView()
    let viewModel: TimeSelectionViewModel

    // Edit Mode Properties
    var isEditMode: Bool = false
    var hobbyId: Int?
    var onChangeComplete: (() -> Void)?

    private let updateHobbyTimeUseCase = UpdateHobbyTimeUseCase()

    // MARK: - Initialization

    init(viewModel: TimeSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = timeView
    }

    override func viewDidLoad() {
        // 수정 모드일 때 프로그래스바 생성 스킵
        shouldSkipProgressBar = isEditMode
        super.viewDidLoad()
        setNavigationTitle("취미 시간")
        // Edit Mode에서는 다음 버튼 숨김 (변경하기 버튼 사용)
        if isEditMode {
            hideNextButton()
        }
        setupHobbyCard()
        setupSlider()
        setupEditMode()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isEditMode {
            updateProgress(0.4)
        }
    }

    private func setupHobbyCard() {
        guard let onboardingData = coordinator?.getOnboardingData(),
              let hobbyCard = onboardingData.selectedHobbyCard else {
            return
        }

        // 아이콘 이미지 설정
        let icon = hobbyCard.imageAsset.icon

        timeView.configureHobbyCard(icon: icon, title: hobbyCard.name)
    }

    private func setupEditMode() {
        guard isEditMode else { return }

        // Enable edit mode on view
        timeView.setEditMode(true)

        // Hide base onboarding navigation
        hideProgressBar()
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Setup callbacks
        timeView.onCloseButtonTapped = { [weak self] in
            self?.dismiss(animated: true)
        }

        timeView.onChangeButtonTapped = { [weak self] in
            self?.handleChangeButtonTapped()
        }
    }

    // MARK: - Edit Mode Configuration

    func configureForEditMode(hobbyId: Int, icon: UIImage?, title: String) {
        self.isEditMode = true
        self.hobbyId = hobbyId
        timeView.configureHobbyCard(icon: icon, title: title)
    }

    // MARK: - Actions

    override func nextButtonTapped() {
        guard viewModel.selectedTime != nil else { return }
        guard !isTransitioning else { return }
        guard coordinator != nil else { return }
        startTransition()
        coordinator?.next(from: .time)
    }

    private func handleChangeButtonTapped() {
        guard let hobbyId = hobbyId else { return }

        // Get selected minutes from slider
        let selectedMinutes = timeView.timeSlider.timeOptions[timeView.timeSlider.selectedIndex]

        Task {
            do {
                _ = try await updateHobbyTimeUseCase.execute(hobbyId: hobbyId, minutes: selectedMinutes)

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

extension TimeSelectionViewController {
    private func setupSlider() {
        timeView.timeSlider.onValueChanged = { [weak self] time in
            self?.viewModel.selectTime(time)
            self?.timeView.selectedHobbyCard.setSelected(true)
            // 선택한 시간을 HobbyCard에 실시간 표시
            self?.timeView.selectedHobbyCard.updateInfo(time: time)
        }
    }

    private func bind() {
        // 다음 버튼 활성화 상태 바인딩 (온보딩 모드에서만)
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                guard let self, !self.isEditMode else { return }
                self.setNextButtonEnabled(isEnabled)
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
