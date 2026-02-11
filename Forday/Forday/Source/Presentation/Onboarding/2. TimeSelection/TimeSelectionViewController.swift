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
        hideNextButton()
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

    private func autoAdvance() {
        // Skip auto-advance in edit mode
        guard !isEditMode else { return }
        guard viewModel.selectedTime != nil else { return }
        guard !isTransitioning else { return }

        // 이전 자동 진행 작업 취소
        autoAdvanceWorkItem?.cancel()

        // 화면 전환 시작
        startTransition()

        // 다음 화면으로 (약간의 딜레이 후)
        let workItem = DispatchWorkItem { [weak self] in
            self?.coordinator?.next(from: .time)
        }
        autoAdvanceWorkItem = workItem

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
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
            self?.autoAdvance()
        }
    }

    private func bind() {
        // 슬라이더는 항상 활성화되어 있으므로 바인딩 불필요
    }
}

#Preview {
    let nav = UINavigationController()
    let coordinator = OnboardingCoordinator(navigationController: nav)
    coordinator.show(.time)
    return nav
}
