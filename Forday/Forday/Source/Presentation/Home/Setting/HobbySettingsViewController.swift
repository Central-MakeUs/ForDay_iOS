//
//  HobbySettingsViewController.swift
//  Forday
//
//  Created by Subeen on 1/22/26.
//

import UIKit
import Combine

class HobbySettingsViewController: UIViewController {

    // MARK: - Properties

    private let hobbySettingsView = HobbySettingsView()
    private let viewModel: HobbySettingsViewModel
    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: MainTabBarCoordinator?

    // OnboardingCoordinator를 강하게 참조하여 메모리에서 해제되지 않도록 함
    private var onboardingCoordinator: OnboardingCoordinator?

    // MARK: - Initialization

    init(viewModel: HobbySettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = hobbySettingsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavigationBar()
        setupTableView()
        setupSegmentedControl()
        bind()
        fetchInitialData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 커스텀 내비게이션 사용으로 기본 내비게이션 바 숨김
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup

    private func setupCustomNavigationBar() {
        hobbySettingsView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    @objc private func backButtonTapped() {
        // Pop if in navigation stack, otherwise dismiss
        if let navController = navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func setupTableView() {
        hobbySettingsView.tableView.dataSource = self
        hobbySettingsView.tableView.delegate = self
    }

    private func setupSegmentedControl() {
        hobbySettingsView.segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }

    private func bind() {
        // Bind hobbies changes to reload table view
        viewModel.$hobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hobbySettingsView.reloadTableView()
            }
            .store(in: &cancellables)

        // Bind showAddHobbyCell changes to reload table view
        viewModel.$showAddHobbyCell
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hobbySettingsView.reloadTableView()
            }
            .store(in: &cancellables)

        // Bind counts to update segmented control
        Publishers.CombineLatest3(viewModel.$inProgressCount, viewModel.$archivedCount, viewModel.$currentStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inProgressCount, archivedCount, currentStatus in
                let selectedIndex = currentStatus == .inProgress ? 0 : 1
                self?.hobbySettingsView.updateSegmentedControl(
                    inProgressCount: inProgressCount,
                    archivedCount: archivedCount,
                    selectedIndex: selectedIndex
                )
            }
            .store(in: &cancellables)

        // Bind error messages
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }

    private func fetchInitialData() {
        Task { [weak self] in
            do {
                try await self?.viewModel.fetchHobbies(status: .inProgress)
            } catch {
                // Error already handled via binding
            }
        }
    }

    // MARK: - Actions

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let status: HobbyStatus = sender.selectedSegmentIndex == 0 ? .inProgress : .archived
        hobbySettingsView.animateUnderline(to: sender.selectedSegmentIndex)
        Task { [weak self] in
            await self?.viewModel.switchSegment(to: status)
        }
    }

    /// 프로그래밍 방식으로 탭 전환
    private func switchToTab(_ status: HobbyStatus) {
        print("🔄 switchToTab called with status: \(status)")
        let index = status == .inProgress ? 0 : 1
        hobbySettingsView.segmentedControl.selectedSegmentIndex = index
        print("🔄 segmentedControl.selectedSegmentIndex set to: \(index)")
        hobbySettingsView.animateUnderline(to: index)
        print("🔄 animateUnderline called")
        Task { [weak self] in
            print("🔄 calling viewModel.switchSegment")
            await self?.viewModel.switchSegment(to: status)
            print("🔄 viewModel.switchSegment completed")
        }
    }

    private func handleArchive(hobbyId: Int) {
        // Find hobby name for alert message
        guard let hobby = viewModel.hobbies.first(where: { $0.hobbyId == hobbyId }) else {
            return
        }

        let popupVC = CommonPopupViewController(
            title: "'\(hobby.hobbyName)' 취미를 보관하시겠어요?",
            message: "저장된 기록과 함께 보관함에서 다시 꺼낼 수 있어요!",
            primaryButtonTitle: "보관",
            secondaryButtonTitle: "닫기"
        )
        popupVC.onPrimaryAction = { [weak self] in
            self?.performArchive(hobbyId: hobbyId, hobbyName: hobby.hobbyName)
        }

        present(popupVC, animated: true)
    }

    private func performArchive(hobbyId: Int, hobbyName: String) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.archiveHobby(hobbyId: hobbyId)
                await MainActor.run {
                    // Notify other screens that a hobby was archived
                    AppEventBus.shared.hobbyDeleted.send()

                    // Show success toast with navigation action
                    ToastView.show(
                        message: "'\(hobbyName)' 취미를 보관했어요.",
                        actionTitle: "이동하기",
                        duration: 3.0,
                        onAction: { [weak self] in
                            print("🍞 Toast action tapped - archive")
                            guard let self = self else {
                                print("❌ self is nil")
                                return
                            }
                            // Switch to archived tab
                            self.switchToTab(.archived)
                        }
                    )
                }
            } catch {
                // Error already handled via binding
            }
        }
    }

    private func handleUnarchive(hobbyId: Int) {
        // Find hobby name for alert message
        guard let hobby = viewModel.hobbies.first(where: { $0.hobbyId == hobbyId }) else {
            return
        }

        let popupVC = CommonPopupViewController(
            title: "'\(hobby.hobbyName)' 취미를 꺼내시겠어요?",
            message: "저장된 기록으로 다시 '\(hobby.hobbyName)' 취미를 시작할 수 있어요!",
            primaryButtonTitle: "꺼내기",
            secondaryButtonTitle: "닫기"
        )
        popupVC.onPrimaryAction = { [weak self] in
            self?.performUnarchive(hobbyId: hobbyId, hobbyName: hobby.hobbyName)
        }

        present(popupVC, animated: true)
    }

    private func performUnarchive(hobbyId: Int, hobbyName: String) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.unarchiveHobby(hobbyId: hobbyId)
                await MainActor.run {
                    // Notify other screens that a hobby was restored
                    AppEventBus.shared.hobbyDeleted.send()

                    // Show success toast with navigation action
                    ToastView.show(
                        message: "'\(hobbyName)' 취미를 꺼냈어요.",
                        actionTitle: "이동하기",
                        duration: 3.0,
                        onAction: { [weak self] in
                            print("🍞 Toast action tapped - unarchive")
                            guard let self = self else {
                                print("❌ self is nil")
                                return
                            }
                            // Switch to in-progress tab
                            self.switchToTab(.inProgress)
                        }
                    )
                }
            } catch {
                // Error already handled via binding
            }
        }
    }

    private func handleTimeEdit(hobbyId: Int) {
        // Find current hobby to get current time
        guard let hobby = viewModel.hobbies.first(where: { $0.hobbyId == hobbyId }) else {
            return
        }

        // Create ViewModel
        let timeViewModel = TimeSelectionViewModel()
        // Convert minutes to time string format
        let timeString = convertMinutesToTimeString(hobby.hobbyTimeMinutes)
        timeViewModel.selectTime(timeString)

        // Create ViewController with edit mode
        let timeVC = TimeSelectionViewController(viewModel: timeViewModel)
        timeVC.isEditMode = true
        timeVC.hobbyId = hobbyId
        timeVC.onChangeComplete = { [weak self] in
            guard let self = self else { return }
            // Notify HomeViewController to refresh hobby info
            AppEventBus.shared.hobbySettingsUpdated.send(hobbyId)
            // Refresh current list
            self.refreshCurrentList()
        }

        // Configure hobby card for edit mode
        timeVC.configureForEditMode(
            hobbyId: hobbyId,
            icon: hobby.imageAsset.icon,
            title: hobby.hobbyName
        )

        let nav = BaseNavigationController(rootViewController: timeVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func convertMinutesToTimeString(_ minutes: Int) -> String {
        switch minutes {
        case 10: return "10분"
        case 20: return "20분"
        case 30: return "30분"
        case 60: return "1시간"
        case 120: return "2시간"
        default: return "30분" // Default fallback
        }
    }

    private func handleExecutionEdit(hobbyId: Int) {
        // Find current hobby to get current frequency
        guard let hobby = viewModel.hobbies.first(where: { $0.hobbyId == hobbyId }) else {
            return
        }

        // Create ViewModel
        let frequencyViewModel = FrequencySelectionViewModel()

        // Pre-select current frequency
        if let index = frequencyViewModel.frequencies.firstIndex(where: { $0.count == hobby.executionCount }) {
            frequencyViewModel.selectFrequency(at: index)
        }

        // Create ViewController with edit mode
        let frequencyVC = FrequencySelectionViewController(viewModel: frequencyViewModel)
        frequencyVC.isEditMode = true
        frequencyVC.hobbyId = hobbyId
        frequencyVC.onChangeComplete = { [weak self] in
            guard let self = self else { return }
            // Notify HomeViewController to refresh hobby info
            AppEventBus.shared.hobbySettingsUpdated.send(hobbyId)
            // Refresh current list
            self.refreshCurrentList()
        }

        // Configure hobby card for edit mode
        frequencyVC.configureForEditMode(
            hobbyId: hobbyId,
            icon: hobby.imageAsset.icon,
            title: hobby.hobbyName,
            time: hobby.timeDisplayText,
            purpose: nil
        )

        let nav = BaseNavigationController(rootViewController: frequencyVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func handleGoalDaysEdit(hobbyId: Int) {
        // Find current hobby to get current goal days setting
        guard let hobby = viewModel.hobbies.first(where: { $0.hobbyId == hobbyId }) else {
            return
        }

        // Create ViewModel
        let periodViewModel = PeriodSelectionViewModel()

        // Pre-select based on current goal days
        let isDurationSet = hobby.goalDays != nil
        if let index = periodViewModel.periods.firstIndex(where: {
            $0.type == (isDurationSet ? .fixed : .flexible)
        }) {
            periodViewModel.selectPeriod(at: index)
        }

        // Create ViewController with edit mode
        let periodVC = PeriodSelectionViewController(viewModel: periodViewModel)
        periodVC.isEditMode = true
        periodVC.hobbyId = hobbyId
        periodVC.onChangeComplete = { [weak self] in
            guard let self = self else { return }
            // Notify HomeViewController to refresh hobby info
            AppEventBus.shared.hobbySettingsUpdated.send(hobbyId)
            // Refresh current list
            self.refreshCurrentList()
        }

        // Configure hobby card for edit mode
        periodVC.configureForEditMode(
            hobbyId: hobbyId,
            icon: hobby.imageAsset.icon,
            title: hobby.hobbyName,
            time: hobby.timeDisplayText,
            frequency: hobby.executionDisplayText,
            purpose: nil
        )

        let nav = BaseNavigationController(rootViewController: periodVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func refreshCurrentList() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.fetchHobbies(status: self.viewModel.currentStatus)
            } catch {
                // Error already handled via binding
            }
        }
    }

    private func handleAddHobbyTapped() {
        // Start onboarding flow in current navigation controller
        guard let navigationController = navigationController else { return }

        // Create onboarding coordinator with current navigation controller
        // Store as property to prevent deallocation
        onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)

        // 취미 추가 모드로 설정 (이미 생성한 취미 제외)
        onboardingCoordinator?.hobbySelectionMode = .addHobby

        // Set completion handler to pop back to HobbySettings
        onboardingCoordinator?.onHobbyCreationCompleted = { [weak self] in
            guard let self = self else { return }

            // Pop all onboarding screens and return to HobbySettings
            self.navigationController?.popToViewController(self, animated: true)

            // Clear onboarding coordinator reference
            self.onboardingCoordinator = nil

            // Refresh hobby list
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    try await self.viewModel.fetchHobbies(status: self.viewModel.currentStatus)
                } catch {
                    // Error already handled via binding
                }
            }
        }

        // Start onboarding flow (hobby selection)
        onboardingCoordinator?.start()
    }

    private func showErrorAlert(message: String) {
        ToastView.showError(message: message)
    }
}

// MARK: - UITableViewDataSource

extension HobbySettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let hobbyCount = viewModel.hobbies.count
        let showAddCell = viewModel.showAddHobbyCell
        return hobbyCount + (showAddCell ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check if this is the "Add Hobby" cell
        if viewModel.showAddHobbyCell && indexPath.row == viewModel.hobbies.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddHobbyCell.identifier, for: indexPath) as? AddHobbyCell else {
                return UITableViewCell()
            }

            cell.onTapped = { [weak self] in
                self?.handleAddHobbyTapped()
            }

            return cell
        }

        // Otherwise, return a HobbySettingsCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HobbySettingsCell.identifier, for: indexPath) as? HobbySettingsCell else {
            return UITableViewCell()
        }

        let hobby = viewModel.hobbies[indexPath.row]
        let isArchived = viewModel.currentStatus == .archived

        cell.configure(with: hobby, isArchived: isArchived)

        // Set callbacks
        cell.onArchiveTapped = { [weak self] hobbyId in
            self?.handleArchive(hobbyId: hobbyId)
        }

        cell.onUnarchiveTapped = { [weak self] hobbyId in
            self?.handleUnarchive(hobbyId: hobbyId)
        }

        cell.onTimeEditTapped = { [weak self] hobbyId in
            self?.handleTimeEdit(hobbyId: hobbyId)
        }

        cell.onExecutionEditTapped = { [weak self] hobbyId in
            self?.handleExecutionEdit(hobbyId: hobbyId)
        }

        cell.onGoalDaysEditTapped = { [weak self] hobbyId in
            self?.handleGoalDaysEdit(hobbyId: hobbyId)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension HobbySettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
