//
//  ActivityListViewController.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//

import UIKit
import Combine
import SnapKit

class ActivityListViewController: UIViewController {

    // MARK: - Properties

    private let listView = ActivityListView()
    private let viewModel: ActivityListViewModel
    private let hobbyId: Int
    private var cancellables = Set<AnyCancellable>()

    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // AI Recommendation Toast
    var shouldShowAIRecommendationToast = false
    var aiCallRemaining = true  // AI 호출 가능 여부
    private var aiToastView: AIRecommendationToastView?

    // Modal Presentation
    var isPresentedModally = false

    // MARK: - Initialization

    init(hobbyId: Int, viewModel: ActivityListViewModel = ActivityListViewModel()) {
        self.hobbyId = hobbyId
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = listView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupActions()
        bind()
        loadActivities()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Show AI recommendation toast if needed
        if shouldShowAIRecommendationToast {
            shouldShowAIRecommendationToast = false
            showAIRecommendationToast()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Setup

extension ActivityListViewController {
    private func setupTableView() {
        listView.tableView.delegate = self
        listView.tableView.dataSource = self
    }

    private func setupActions() {
        // Custom Navigation Buttons
        listView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        listView.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        // Empty State Button
        listView.onCreateActivityTapped = { [weak self] in
            self?.navigateToActivityInput()
        }
    }

    private func navigateToActivityInput() {
        let inputVC = HobbyActivityInputViewController(hobbyId: hobbyId)
        inputVC.aiCallRemaining = aiCallRemaining
        inputVC.onActivityCreated = { [weak self] in
            self?.dismiss(animated: true) {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }

        let nav = UINavigationController(rootViewController: inputVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func bind() {
        // 활동 목록 업데이트
        viewModel.$activities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.listView.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)

        // 로딩 상태
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: 로딩 인디케이터
                print(isLoading ? "로딩 중..." : "로딩 완료")
            }
            .store(in: &cancellables)

        // 에러 처리
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
    }

    private func loadActivities() {
        Task {
            await viewModel.fetchActivities(hobbyId: hobbyId)
        }
    }

    private func updateEmptyState() {
        listView.setEmptyState(viewModel.activities.isEmpty)
    }
}

// MARK: - Actions

extension ActivityListViewController {
    @objc private func backButtonTapped() {
        if isPresentedModally {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func addButtonTapped() {
        let inputVC = HobbyActivityInputViewController(hobbyId: hobbyId)
        inputVC.aiCallRemaining = aiCallRemaining
        inputVC.onActivityCreated = { [weak self] in
            // Dismiss modal first, then pop to HomeViewController
            self?.dismiss(animated: true) {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }

        let nav = UINavigationController(rootViewController: inputVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func showEditPopup(for activity: Activity) {
        let popup = TextInputPopupViewController(
            title: "활동 수정",
            placeholder: "활동 내용을 입력해주세요"
        )
        popup.initialText = activity.content
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve

        popup.onSubmit = { [weak self] newContent in
            self?.updateActivity(activityId: activity.activityId, content: newContent)
        }

        present(popup, animated: true)
    }

    private func showDeletePopup(for activity: Activity) {
        let popup = CommonPopupViewController(
            title: "이 활동을 삭제하시겠어요?",
            message: "삭제 시 복구는 안돼요!",
            primaryButtonTitle: "삭제하기",
            secondaryButtonTitle: "닫기"
        )

        popup.onPrimaryAction = { [weak self] in
            self?.deleteActivity(activityId: activity.activityId)
        }

        present(popup, animated: true)
    }

    private func updateActivity(activityId: Int, content: String) {
        Task {
            do {
                try await viewModel.updateActivity(activityId: activityId, content: content)
                await viewModel.fetchActivities(hobbyId: hobbyId)  // 새로고침

                // 홈 화면 업데이트를 위한 이벤트 발생
                await MainActor.run {
                    AppEventBus.shared.activityUpdated.send(hobbyId)
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

    private func deleteActivity(activityId: Int) {
        Task {
            do {
                try await viewModel.deleteActivity(activityId: activityId)

                // 홈 화면 업데이트를 위한 이벤트 발생
                await MainActor.run {
                    AppEventBus.shared.activityDeleted.send(hobbyId)
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

    private func handleError(_ error: AppError) {
        let title: String
        let message = error.userMessage
        var actions: [UIAlertAction] = []

        switch error {
        case .network:
            title = "네트워크 오류"
            actions.append(UIAlertAction(title: "다시 시도", style: .default) { [weak self] _ in
                self?.loadActivities()
            })
            actions.append(UIAlertAction(title: "취소", style: .cancel))

        case .server:
            title = "오류"
            actions.append(UIAlertAction(title: "확인", style: .default))

        case .decoding, .unknown:
            title = "오류"
            actions.append(UIAlertAction(title: "확인", style: .default))
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }

    private func showError(_ message: String) {
        ToastView.showError(message: message)
    }

    private func showAIRecommendationToast() {
        let toast = AIRecommendationToastView()
        toast.configure(with: "포데이 AI가 알맞은 취미활동을 추천해드려요")

        // Set tap callback
        toast.onTap = { [weak self] in
            self?.aiToastTapped()
        }

        // Add to view
        view.addSubview(toast)
        toast.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }

        // Expand animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            toast.expand(animated: true)
        }

        aiToastView = toast
    }

    private func aiToastTapped() {
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
                let aiRecommendations = try await viewModel.fetchAIRecommendations(hobbyId: hobbyId)

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
        // Select 모드: AI 추천 활동 선택 후 HobbyActivityInputView로 이동
        let selectionView = AIActivitySelectionView(result: result)

        selectionView.onActivitySelected = { [weak self] content in
            guard let self = self else { return }

            // Dismiss AI selection view
            self.dismiss(animated: true) {
                // Open HobbyActivityInputViewController with AI content
                self.openActivityInputWithAIContent(content)
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

    private func openActivityInputWithAIContent(_ content: String) {
        let inputVC = HobbyActivityInputViewController(hobbyId: hobbyId)
        inputVC.aiCallRemaining = aiCallRemaining
        inputVC.aiRecommendedContent = content  // AI 추천 활동 내용 전달 (aiRecommended: true)

        inputVC.onActivityCreated = { [weak self] in
            // Dismiss modal first, then pop to HomeViewController
            self?.dismiss(animated: true) {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }

        let nav = UINavigationController(rootViewController: inputVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ActivityListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.activities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCardCell.identifier, for: indexPath) as? ActivityCardCell else {
            return UITableViewCell()
        }

        let activity = viewModel.activities[indexPath.row]
        cell.configure(with: activity)

        cell.onEditTapped = { [weak self] in
            self?.showEditPopup(for: activity)
        }

        cell.onDeleteTapped = { [weak self] in
            self?.showDeletePopup(for: activity)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ActivityListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ActivityCardCell.cellHeight
    }
}

#if DEBUG
#Preview {
    ActivityListViewController(hobbyId: 1)
}
#endif
