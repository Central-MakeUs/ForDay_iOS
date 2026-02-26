//
//  UserProfileViewController.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class UserProfileViewController: UIViewController {

    // MARK: - Properties

    private var userProfileView: UserProfileView {
        return view as! UserProfileView
    }

    private let viewModel: UserProfileViewModel
    private var cancellables = Set<AnyCancellable>()

    weak var coordinator: MainTabBarCoordinator?

    // Child ViewControllers for tab content
    private var activityGridVC: ActivityGridViewController?
    private var hobbyCardStackVC: HobbyCardStackViewController?
    private var scrapGridVC: ScrapGridViewController?

    // Dropdown
    private var dropdownBackgroundView: UIView?
    private var dropdownView: DropdownMenuView<UserProfileMenuItem>?

    // Track if this is the first load
    private var isFirstLoad = true

    // MARK: - Initialization

    init(userId: String) {
        self.viewModel = UserProfileViewModel(userId: userId)
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = UserProfileView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupRefreshControl()
        setupSegmentedControl()
        setupScrollView()
        bind()
        loadUserProfileData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Private Methods

    private func loadUserProfileData() {
        userProfileView.showSkeleton()

        Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.fetchInitialData()

            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.userProfileView.hideSkeleton()

                if self.isFirstLoad {
                    self.setupChildViewControllers()
                    self.switchToTab(.activities)
                    self.isFirstLoad = false
                }
            }
        }
    }
}

// MARK: - Setup

extension UserProfileViewController {
    private func setupNavigationBar() {
        userProfileView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        userProfileView.moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
    }

    private func setupRefreshControl() {
        userProfileView.refreshControl.addTarget(
            self,
            action: #selector(refreshData),
            for: .valueChanged
        )
    }

    private func setupSegmentedControl() {
        userProfileView.segmentedControlView.onSegmentChanged = { [weak self] tab in
            self?.viewModel.switchTab(to: tab)
        }
    }

    private func setupScrollView() {
        userProfileView.scrollView.delegate = self
    }

    private func bind() {
        // User profile
        viewModel.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let profile = profile else { return }
                self?.userProfileView.headerView.configure(with: profile)
            }
            .store(in: &cancellables)

        // Current tab
        viewModel.$currentTab
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tab in
                self?.switchToTab(tab)
            }
            .store(in: &cancellables)

        // Segment counts
        Publishers.CombineLatest(
            viewModel.$inProgressHobbyCount,
            viewModel.$hobbyCardCount
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] inProgressCount, hobbyCardsCount in
            self?.userProfileView.segmentedControlView.updateCounts(
                inProgressCount: inProgressCount,
                hobbyCardsCount: hobbyCardsCount
            )
        }
        .store(in: &cancellables)

        // Error handling
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.handleAppError(error)
            }
            .store(in: &cancellables)

        // Blocked state
        viewModel.$isBlocked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isBlocked in
                if isBlocked {
                    self?.userProfileView.showBlockedState()
                } else {
                    self?.userProfileView.hideBlockedState()
                }
            }
            .store(in: &cancellables)
    }

    private func setupChildViewControllers() {
        // Activity Grid ViewController
        let activityGridVC = ActivityGridViewController(viewModel: viewModel)
        activityGridVC.coordinator = coordinator
        activityGridVC.onContentHeightChanged = { [weak self] height in
            self?.userProfileView.updateContentHeight(height)
        }
        addChild(activityGridVC)
        userProfileView.contentContainerView.addSubview(activityGridVC.view)
        activityGridVC.view.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        activityGridVC.didMove(toParent: self)
        self.activityGridVC = activityGridVC

        // Hobby Card Stack ViewController
        let hobbyCardStackVC = HobbyCardStackViewController(viewModel: viewModel)
        addChild(hobbyCardStackVC)
        userProfileView.contentContainerView.addSubview(hobbyCardStackVC.view)
        hobbyCardStackVC.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        hobbyCardStackVC.didMove(toParent: self)
        self.hobbyCardStackVC = hobbyCardStackVC

        // Scrap Grid ViewController
        let scrapGridVC = ScrapGridViewController(viewModel: viewModel)
        scrapGridVC.coordinator = coordinator
        scrapGridVC.onContentHeightChanged = { [weak self] height in
            self?.userProfileView.updateContentHeight(height)
        }
        addChild(scrapGridVC)
        userProfileView.contentContainerView.addSubview(scrapGridVC.view)
        scrapGridVC.view.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        scrapGridVC.didMove(toParent: self)
        self.scrapGridVC = scrapGridVC

        // Initially hide all except activities
        hobbyCardStackVC.view.isHidden = true
        scrapGridVC.view.isHidden = true
    }

    private func switchToTab(_ tab: MyPageTab) {
        // Toggle visibility instead of removing/adding views
        activityGridVC?.view.isHidden = tab != .activities
        hobbyCardStackVC?.view.isHidden = tab != .hobbyCards
        scrapGridVC?.view.isHidden = tab != .scraps
    }
}

// MARK: - Actions

extension UserProfileViewController {
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func moreButtonTapped() {
        if dropdownView != nil {
            dismissDropdown()
        } else {
            showDropdown()
        }
    }

    @objc private func refreshData() {
        Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.fetchInitialData()

            await MainActor.run { [weak self] in
                self?.userProfileView.refreshControl.endRefreshing()
            }
        }
    }

    private func showDropdown() {
        dismissDropdown()

        // Background view
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        view.addSubview(backgroundView)

        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDropdown))
        backgroundView.addGestureRecognizer(tapGesture)

        // Dropdown menu
        let dropdown = DropdownMenuView(items: UserProfileMenuItem.menuItems)
        dropdown.onItemSelected = { [weak self] menuItem in
            self?.handleMenuSelection(menuItem)
        }
        dropdown.showInParent(view, below: userProfileView.moreButton)

        dropdownBackgroundView = backgroundView
        dropdownView = dropdown
    }

    @objc private func dismissDropdown() {
        dropdownView?.dismiss()
        dropdownBackgroundView?.removeFromSuperview()
        dropdownView = nil
        dropdownBackgroundView = nil
    }

    private func handleMenuSelection(_ menuItem: UserProfileMenuItem) {
        dismissDropdown()

        switch menuItem {
        case .block:
            showBlockConfirmation()
        case .report:
            showReportOptions()
        }
    }

    private func showBlockConfirmation() {
        guard let profile = viewModel.userProfile else { return }

        let popupVC = CommonPopupViewController(
            title: "\(profile.nickname)님을 차단하시겠어요?",
            message: "\(profile.nickname) 님이 올리는 모든 활동기록은 숨김처리되며, 회원님의 프로필 또는 활동기록은 공개되지 않습니다.\n상대방에게는 회원님이 차단한 사실은 알려지지 않으며, 언제든지 차단 해지 가능합니다.",
            primaryButtonTitle: "예",
            secondaryButtonTitle: "아니오"
        )
        popupVC.onPrimaryAction = { [weak self] in
            self?.performBlock()
        }

        present(popupVC, animated: true)
    }

    private func performBlock() {
        Task { [weak self] in
            guard let self = self else { return }

            do {
                let friendsService = FriendsService()
                let response = try await friendsService.blockUser(userId: self.viewModel.userId)

                await MainActor.run { [weak self] in
                    guard let self = self else { return }

                    // Show toast with API response message
                    if let data = response.data {
                        ToastView.showSuccess(message: data.message)
                    }

                    // Show blocked state
                    self.viewModel.isBlocked = true
                    self.userProfileView.showBlockedState()
                }
            } catch {
                await MainActor.run { [weak self] in
                    if let appError = error as? AppError {
                        ToastView.showError(message: appError.userMessage)
                    } else {
                        ToastView.showError(message: "차단 처리 중 오류가 발생했습니다.")
                    }
                }
            }
        }
    }

    private func showReportOptions() {
        guard let profile = viewModel.userProfile else { return }

        // 사용자 신고는 차단 확인 바텀시트로 바로 이동
        let bottomSheet = BlockUserBottomSheetViewController(
            nickname: profile.nickname,
            onConfirm: { [weak self] shouldBlock in
                self?.handleUserReport(shouldBlock: shouldBlock)
            }
        )
        bottomSheet.modalPresentationStyle = .pageSheet

        if let sheet = bottomSheet.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 280 })]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(bottomSheet, animated: true)
    }

    private func handleUserReport(shouldBlock: Bool) {
        Task { [weak self] in
            guard let self = self else { return }

            do {
                // 차단 요청 시 API 호출
                if shouldBlock {
                    let friendsService = FriendsService()
                    _ = try await friendsService.blockUser(userId: self.viewModel.userId)
                }

                await MainActor.run { [weak self] in
                    ToastView.showSuccess(message: "신고가 접수되었습니다.")
                    self?.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    if let appError = error as? AppError {
                        ToastView.showError(message: appError.userMessage)
                    } else {
                        ToastView.showError(message: "처리 중 오류가 발생했습니다.")
                    }
                }
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension UserProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch viewModel.currentTab {
        case .activities:
            activityGridVC?.checkLoadMoreIfNeeded(scrollView: scrollView)
        case .scraps:
            scrapGridVC?.checkLoadMoreIfNeeded(scrollView: scrollView)
        case .hobbyCards:
            break
        }
    }
}

#Preview {
    UserProfileViewController(userId: "test-user-id")
}
