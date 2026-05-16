//
//  NewHobbySettingsViewController.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//

import UIKit
import SnapKit
import Then
import Combine

/// 새로운 취미설정 화면
class NewHobbySettingsViewController: UIViewController {

    // MARK: - Properties

    private let hobbySettingsView = NewHobbySettingsView()
    private let viewModel: NewHobbySettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // MARK: - Initialization

    init(viewModel: NewHobbySettingsViewModel) {
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
        setupNavigationBar()
        setupTableView()
        setupButtons()
        bind()
        fetchInitialData()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupTableView() {
        hobbySettingsView.tableView.dataSource = self
        hobbySettingsView.tableView.delegate = self
        hobbySettingsView.tableView.dragDelegate = self
        hobbySettingsView.tableView.dropDelegate = self
    }

    private func setupButtons() {
        hobbySettingsView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        hobbySettingsView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        hobbySettingsView.trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
        hobbySettingsView.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        hobbySettingsView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }

    private func bind() {
        // Bind progress hobbies changes to reload table view
        viewModel.$progressHobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hobbySettingsView.tableView.reloadData()
            }
            .store(in: &cancellables)

        // Bind hidden hobbies changes to reload table view
        viewModel.$hiddenHobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hobbySettingsView.tableView.reloadData()
            }
            .store(in: &cancellables)

        // Bind hasChanges to save button state
        viewModel.$hasChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasChanges in
                self?.hobbySettingsView.updateSaveButtonState(isEnabled: hasChanges)
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

        // Bind deletion mode to reload table view and update navigation
        viewModel.$isDeletionMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDeletionMode in
                self?.hobbySettingsView.updateNavigationForDeletionMode(isDeletionMode: isDeletionMode)
                self?.hobbySettingsView.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func fetchInitialData() {
        Task { [weak self] in
            do {
                try await self?.viewModel.fetchHobbies()
            } catch {
                // Error already handled via binding
            }
        }
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        // Check if there are unsaved changes
        if viewModel.hasChanges {
            // Show confirmation popup
            let popup = CommonPopupViewController(
                title: "편집 중인 화면을 닫으시겠습니까?",
                message: "지금까지 변경한 내용은 저장되지 않습니다.",
                primaryButtonTitle: "닫기",
                secondaryButtonTitle: "취소"
            )

            popup.onPrimaryAction = { [weak self] in
                // Discard changes and go back
                self?.performBackNavigation()
            }

            // onSecondaryAction does nothing - just dismisses popup

            present(popup, animated: true)
        } else {
            // No changes, just go back
            performBackNavigation()
        }
    }

    private func performBackNavigation() {
        if let navController = navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func saveButtonTapped() {
        Task { [weak self] in
            do {
                try await self?.viewModel.saveChanges()
                await MainActor.run {
                    // Show success toast
                    ToastView.show(message: "취미 설정이 저장되었습니다.")
                }
            } catch {
                // Error already handled via binding
            }
        }
    }

    @objc private func trashButtonTapped() {
        if viewModel.hasChanges {
            // Show save confirmation popup
            let popup = CommonPopupViewController(
                title: "변경된 내용을 저장하시겠습니까?",
                message: "취소하면 변경된 내용이 초기화됩니다.",
                primaryButtonTitle: "저장",
                secondaryButtonTitle: "취소"
            )

            popup.onPrimaryAction = { [weak self] in
                // Save changes first, then toggle deletion mode
                Task { @MainActor [weak self] in
                    do {
                        try await self?.viewModel.saveChanges()
                        self?.viewModel.toggleDeletionMode()
                    } catch {
                        // Error handled via binding
                    }
                }
            }

            popup.onSecondaryAction = { [weak self] in
                // Discard changes and toggle deletion mode
                Task { @MainActor [weak self] in
                    do {
                        try await self?.viewModel.fetchHobbies()
                        self?.viewModel.toggleDeletionMode()
                    } catch {
                        // Error handled via binding
                    }
                }
            }

            present(popup, animated: true)
        } else {
            // No changes, just toggle deletion mode
            viewModel.toggleDeletionMode()
        }
    }

    @objc private func closeButtonTapped() {
        // 삭제 모드 해제
        viewModel.toggleDeletionMode()
    }

    @objc private func plusButtonTapped() {
        if viewModel.hasChanges {
            // Show save confirmation popup
            let popup = CommonPopupViewController(
                title: "변경된 내용을 저장하시겠습니까?",
                message: "취소하면 변경된 내용이 초기화됩니다.",
                primaryButtonTitle: "저장",
                secondaryButtonTitle: "취소"
            )

            popup.onPrimaryAction = { [weak self] in
                // Save changes first, then show add popup
                Task { @MainActor [weak self] in
                    do {
                        try await self?.viewModel.saveChanges()
                        self?.showAddHobbyPopup()
                    } catch {
                        // Error handled via binding
                    }
                }
            }

            popup.onSecondaryAction = { [weak self] in
                // Discard changes and show add popup
                Task { @MainActor [weak self] in
                    do {
                        try await self?.viewModel.fetchHobbies()
                        self?.showAddHobbyPopup()
                    } catch {
                        // Error handled via binding
                    }
                }
            }

            present(popup, animated: true)
        } else {
            // No changes, just show add popup
            showAddHobbyPopup()
        }
    }

    private func showAddHobbyPopup() {
        let popup = TextInputPopupViewController(
            title: "취미 추가",
            placeholder: "취미명을 입력해주세요.",
            maxCharacterCount: 20
        )

        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve

        popup.onSubmit = { [weak self] hobbyName in
            Task { @MainActor [weak self] in
                do {
                    try await self?.viewModel.addHobby(hobbyName: hobbyName)
                    ToastView.show(message: "취미가 추가되었습니다.")
                } catch {
                    // Error already handled via binding
                }
            }
        }

        present(popup, animated: true)
    }

    private func handleDeleteTapped(hobbyId: Int) {
        let popup = CommonPopupViewController(
            title: "취미를 삭제하시겠어요?",
            message: "삭제 시 관련된 모든 활동 기록글이 삭제되며 복구할 수 없습니다.",
            primaryButtonTitle: "삭제하기",
            secondaryButtonTitle: "닫기"
        )

        popup.onPrimaryAction = { [weak self] in
            Task { @MainActor [weak self] in
                do {
                    try await self?.viewModel.deleteHobby(hobbyId: hobbyId)
                    ToastView.show(message: "취미가 삭제되었습니다.")
                } catch {
                    // Error already handled via binding
                }
            }
        }

        present(popup, animated: true)
    }

    private func handleMinusTapped(hobbyId: Int) {
        viewModel.moveToHidden(hobbyId: hobbyId)
    }

    private func handlePlusTapped(hobbyId: Int) {
        viewModel.moveToProgress(hobbyId: hobbyId)
    }

    private func showErrorAlert(message: String) {
        ToastView.showError(message: message)
    }
}

// MARK: - UITableViewDataSource

extension NewHobbySettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Section 0: Progress Hobbies, Section 1: Hidden Hobbies
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.progressHobbies.count
        } else {
            return viewModel.hiddenHobbies.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Progress Hobby Cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProgressHobbyCell.identifier, for: indexPath) as? ProgressHobbyCell else {
                return UITableViewCell()
            }

            let hobby = viewModel.progressHobbies[indexPath.row]
            cell.configure(hobby: hobby, isDeletionMode: viewModel.isDeletionMode)
            cell.onMinusTapped = { [weak self] hobbyId in
                self?.handleMinusTapped(hobbyId: hobbyId)
            }
            cell.onDeleteTapped = { [weak self] hobbyId in
                self?.handleDeleteTapped(hobbyId: hobbyId)
            }

            return cell
        } else {
            // Hidden Hobby Cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HiddenHobbyCell.identifier, for: indexPath) as? HiddenHobbyCell else {
                return UITableViewCell()
            }

            let hobby = viewModel.hiddenHobbies[indexPath.row]
            cell.configure(hobby: hobby, isDeletionMode: viewModel.isDeletionMode)
            cell.onPlusTapped = { [weak self] hobbyId in
                self?.handlePlusTapped(hobbyId: hobbyId)
            }
            cell.onDeleteTapped = { [weak self] hobbyId in
                self?.handleDeleteTapped(hobbyId: hobbyId)
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            // "숨겨진 취미" 헤더 (항상 표시)
            let headerView = UIView()
            headerView.backgroundColor = .clear

            let separatorLine = UIView()
            separatorLine.backgroundColor = .neutral200

            let titleLabel = UILabel()
            titleLabel.setTextWithTypography("숨겨진 취미", style: .label14)
            titleLabel.textColor = .neutral400

            headerView.addSubview(separatorLine)
            headerView.addSubview(titleLabel)

            separatorLine.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(1)
            }

            titleLabel.snp.makeConstraints {
                $0.top.equalTo(separatorLine.snp.bottom).offset(24)
                $0.leading.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-12)
            }

            return headerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return UITableView.automaticDimension
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 && viewModel.hiddenHobbies.isEmpty {
            // Empty state for hidden hobbies section
            let footerView = UIView()
            footerView.backgroundColor = .clear

            let emptyStateIconView = UIImageView()
            emptyStateIconView.image = .Icon.sorryBubble
            emptyStateIconView.contentMode = .scaleAspectFit

            let emptyStateLabel = UILabel()
            emptyStateLabel.setTextWithTypography("숨겨진 취미가 없어요", style: .label14)
            emptyStateLabel.textColor = .neutral400
            emptyStateLabel.textAlignment = .center

            footerView.addSubview(emptyStateIconView)
            footerView.addSubview(emptyStateLabel)

            emptyStateIconView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(40)
                $0.centerX.equalToSuperview()
                $0.width.height.equalTo(48)
            }

            emptyStateLabel.snp.makeConstraints {
                $0.top.equalTo(emptyStateIconView.snp.bottom).offset(12)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-40)
            }

            return footerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 && viewModel.hiddenHobbies.isEmpty {
            return UITableView.automaticDimension
        }
        return 0
    }
}

// MARK: - UITableViewDelegate

extension NewHobbySettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDragDelegate

extension NewHobbySettingsViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // Only allow dragging in progress hobbies section (section 0)
        guard indexPath.section == 0 else { return [] }

        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = viewModel.progressHobbies[indexPath.row]
        return [dragItem]
    }
}

// MARK: - UITableViewDropDelegate

extension NewHobbySettingsViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // Only allow drop in progress hobbies section (section 0)
        guard let destinationIndexPath = destinationIndexPath, destinationIndexPath.section == 0 else {
            return UITableViewDropProposal(operation: .cancel)
        }

        // Allow reordering within the same section
        if tableView.hasActiveDrag {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              destinationIndexPath.section == 0 else { return }

        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath else { return }

            // Reorder hobbies in ViewModel
            viewModel.moveProgressHobby(from: sourceIndexPath.row, to: destinationIndexPath.row)

            // Animate the reorder in TableView
            tableView.performBatchUpdates {
                tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                tableView.insertRows(at: [destinationIndexPath], with: .automatic)
            }

            coordinator.drop(dropItem.dragItem, toRowAt: destinationIndexPath)
        }
    }
}
