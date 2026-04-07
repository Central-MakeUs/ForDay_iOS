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
    private let hobbyName: String
    private var cancellables = Set<AnyCancellable>()
    
    // Callbacks
    var onActivityCreated: (() -> Void)?

    // AI Recommendation
    var aiCallRemaining = true  // AI 호출 가능 여부
    var aiRecommendedContent: String?  // AI 추천 활동 내용 (select 모드에서 전달받음, aiRecommended: true)
    
    // Initialization

    init(hobbyId: Int, hobbyName: String, viewModel: HobbyActivityInputViewModel = HobbyActivityInputViewModel()) {
        self.hobbyId = hobbyId
        self.hobbyName = hobbyName
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
        Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.fetchOthersActivities(hobbyId: self.hobbyId)
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
            image: .Icon.xmark,
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .neutral900
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

        // Analytics: 취미활동 생성 버튼 클릭
        FirebaseAnalyticsService.shared.log(.createHobbyClick)

        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.createActivities(hobbyId: self.hobbyId, activities: activities)

                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    print("✅ 활동 생성 완료! hobbyId: \(self.hobbyId)")

                    // Analytics: 활동 추가 완료
                    // TODO: entryPoint를 HobbyActivityInputViewController에 전달하여 정확한 진입점 로그
                    for activity in activities {
                        let source: ActivitySource = self.aiRecommendedContent != nil ? .aiRecommendation : .manual
                        FirebaseAnalyticsService.shared.log(.activityAdded(
                            entryPoint: .activityListPlus, // 임시: 실제 진입점 전달 필요
                            source: source,
                            hobbyName: self.hobbyName,
                            activityName: activity.content
                        ))
                    }

                    // Call callback without dismissing
                    // Parent view controller will handle dismiss and navigation
                    self.onActivityCreated?()
                }
            } catch let appError as AppError {
                await MainActor.run { [weak self] in
                    self?.showError(appError.userMessage)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }

    private func showError(_ message: String) {
        ToastView.showError(message: message)
    }

    private func handleAIToastTapped() {
        // Analytics: 포데이 AI 추천 활동 보기 클릭
        FirebaseAnalyticsService.shared.log(.hobbyInputViewAIRecommendationsClick)

        // Hide toast
        activityInputView.hideAIRecommendationToast()

        // Show AI recommendation loading
        showAIRecommendationFlow()
    }

    private func showAIRecommendationFlow() {
        // Fullscreen AI 추천 활동 선택 화면 표시
        let containerVC = AIRecommendationContainerViewController(hobbyId: hobbyId, hobbyName: hobbyName)

        containerVC.onActivitySelected = { [weak self] content in
            guard let self = self else { return }
            // Fill the last text field with AI content (aiRecommended: true)
            self.activityInputView.fillLastFieldWithAIRecommendation(content)
            self.validateActivities()
        }

        present(containerVC, animated: true)
    }
}

#Preview {
    let inputVC = HobbyActivityInputViewController(hobbyId: 1, hobbyName: "독서")
    let nav = UINavigationController(rootViewController: inputVC)
    return nav
}
