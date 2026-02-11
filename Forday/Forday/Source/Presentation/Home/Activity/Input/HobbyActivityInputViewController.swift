//
//  HobbyActivityInputViewController.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import UIKit
import Combine

class HobbyActivityInputViewController: UIViewController {
    
    // Properties
    
    private let activityInputView = HobbyActivityInputView()
    private let viewModel: HobbyActivityInputViewModel
    private let hobbyId: Int
    private var cancellables = Set<AnyCancellable>()
    
    // Callbacks
    var onActivityCreated: (() -> Void)?

    // AI Recommendation
    var aiCallRemaining = true  // AI 호출 가능 여부
    var aiRecommendedContent: String?  // AI 추천 활동 내용 (select 모드에서 전달받음, aiRecommended: true)
    
    // Initialization
    
    init(hobbyId: Int, viewModel: HobbyActivityInputViewModel = HobbyActivityInputViewModel()) {
        self.hobbyId = hobbyId
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func loadView() {
        view = activityInputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        bind()

        // 추천 활동 조회
        Task {
            await viewModel.fetchOthersActivities(hobbyId: hobbyId)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // AI 추천 활동 내용이 있으면 마지막 텍스트필드에 채우기 (aiRecommended: true)
        if let content = aiRecommendedContent {
            activityInputView.fillLastFieldWithAIRecommendation(content)
            validateActivities()
            aiRecommendedContent = nil  // 한 번만 적용
        } else {
            // Show AI recommendation toast (prefill이 없을 때만)
            activityInputView.showAIRecommendationToast(aiCallRemaining: aiCallRemaining)
        }
    }
}

// Setup

extension HobbyActivityInputViewController {
    private func setupNavigationBar() {
        title = "취미활동 입력"
        
        // X 버튼
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .label
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setupActions() {
        activityInputView.onSaveButtonTapped = { [weak self] in
            self?.saveActivities()
        }

        activityInputView.onAddButtonTapped = { [weak self] in
            self?.addActivityField()
        }

        activityInputView.onDeleteButtonTapped = { [weak self] index in
            self?.deleteActivityField(at: index)
        }

        activityInputView.onRecommendationButtonTapped = { [weak self] text in
            self?.fillLastFieldWithRecommendation(text)
        }

        activityInputView.onAIToastTapped = { [weak self] in
            self?.handleAIToastTapped()
        }

        activityInputView.onActivitiesChanged = { [weak self] in
            self?.validateActivities()
        }
    }
    
    private func bind() {
        // 저장 버튼 활성화 상태
        viewModel.$isSaveButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.activityInputView.setSaveButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)

        // 로딩 상태
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: 로딩 인디케이터
                print(isLoading ? "저장 중..." : "저장 완료")
            }
            .store(in: &cancellables)

        // 추천 활동 업데이트
        viewModel.$othersActivities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activities in
                self?.activityInputView.setRecommendations(activities)
            }
            .store(in: &cancellables)
    }
}

// Actions

extension HobbyActivityInputViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func addActivityField() {
        activityInputView.addActivityField()
        validateActivities()
    }
    
    private func deleteActivityField(at index: Int) {
        activityInputView.deleteActivityField(at: index)
        validateActivities()
    }
    
    private func validateActivities() {
        let activities = activityInputView.getActivities()
        viewModel.updateActivities(activities)
    }

    private func fillLastFieldWithRecommendation(_ text: String) {
        activityInputView.fillLastFieldWithText(text)
        validateActivities()
    }

    private func saveActivities() {
        let activities = activityInputView.getActivities()

        Task {
            do {
                try await viewModel.createActivities(hobbyId: hobbyId, activities: activities)

                await MainActor.run {
                    print("✅ 활동 생성 완료! hobbyId: \(hobbyId)")

                    // Call callback without dismissing
                    // Parent view controller will handle dismiss and navigation
                    onActivityCreated?()
                }
            } catch let appError as AppError {
                await MainActor.run {
                    showError(appError.userMessage)
                }
            } catch {
                await MainActor.run {
                    showError(error.localizedDescription)
                }
            }
        }
    }

    private func showError(_ message: String) {
        ToastView.showError(message: message)
    }

    private func handleAIToastTapped() {
        // Hide toast
        activityInputView.hideAIRecommendationToast()

        // Show AI recommendation loading
        showAIRecommendationFlow()
    }

    private func showAIRecommendationFlow() {
        // Show loading view
        let loadingVC = AIRecommendationLoadingViewController(hobbyId: hobbyId)
        loadingVC.modalPresentationStyle = .fullScreen
        present(loadingVC, animated: true)

        // Fetch AI recommendations
        Task {
            do {
                let repository = ActivityRepository()
                let aiRecommendations = try await repository.fetchAIRecommendations(hobbyId: hobbyId)

                await MainActor.run {
                    // Dismiss loading and show selection
                    self.dismiss(animated: true) {
                        self.showAISelectionView(with: aiRecommendations)
                    }
                }
            } catch let appError as AppError {
                await MainActor.run {
                    self.dismiss(animated: true) {
                        self.showError(appError.userMessage)
                    }
                }
            } catch {
                await MainActor.run {
                    self.dismiss(animated: true) {
                        self.showError(error.localizedDescription)
                    }
                }
            }
        }
    }

    private func showAISelectionView(with result: AIRecommendationResult) {
        // Select 모드: AI 추천 활동 선택 후 텍스트필드에 채우기
        let selectionView = AIActivitySelectionView(result: result)

        selectionView.onActivitySelected = { [weak self] content in
            guard let self = self else { return }

            // Dismiss AI selection view
            self.dismiss(animated: true) {
                // Fill the last text field with AI content (aiRecommended: true)
                self.activityInputView.fillLastFieldWithAIRecommendation(content)
                self.validateActivities()
            }
        }

        selectionView.onRefreshTapped = { [weak self] in
            self?.dismiss(animated: true) {
                self?.showAIRecommendationFlow()
            }
        }

        selectionView.onError = { [weak self] errorMessage in
            self?.showError(errorMessage)
        }

        // Show as modal
        let containerVC = UIViewController()
        containerVC.view = selectionView
        containerVC.modalPresentationStyle = .pageSheet

        if let sheet = containerVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        present(containerVC, animated: true)
    }
}

#Preview {
    let inputVC = HobbyActivityInputViewController(hobbyId: 1)
    let nav = UINavigationController(rootViewController: inputVC)
    return nav
}
