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
    private var dropdownView: DropdownMenuView?

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
        self.activityGridVC = activityGridVC

        // Hobby Card Stack ViewController
        let hobbyCardStackVC = HobbyCardStackViewController(viewModel: viewModel)
        hobbyCardStackVC.onContentHeightChanged = { [weak self] height in
            self?.userProfileView.updateContentHeight(height)
        }
        addChild(hobbyCardStackVC)
        self.hobbyCardStackVC = hobbyCardStackVC

        // Scrap Grid ViewController
        let scrapGridVC = ScrapGridViewController(viewModel: viewModel)
        scrapGridVC.coordinator = coordinator
        scrapGridVC.onContentHeightChanged = { [weak self] height in
            self?.userProfileView.updateContentHeight(height)
        }
        addChild(scrapGridVC)
        self.scrapGridVC = scrapGridVC
    }

    private func switchToTab(_ tab: MyPageTab) {
        // Remove current child view
        userProfileView.contentContainerView.subviews.forEach { $0.removeFromSuperview() }

        switch tab {
        case .activities:
            if let activityGridVC = activityGridVC {
                userProfileView.contentContainerView.addSubview(activityGridVC.view)
                activityGridVC.view.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(20)
                    $0.leading.trailing.bottom.equalToSuperview()
                }
                activityGridVC.didMove(toParent: self)

                // Refresh content height after layout
                DispatchQueue.main.async {
                    activityGridVC.refreshContentHeight()
                }
            }

        case .hobbyCards:
            if let hobbyCardStackVC = hobbyCardStackVC {
                userProfileView.contentContainerView.addSubview(hobbyCardStackVC.view)
                hobbyCardStackVC.view.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
                hobbyCardStackVC.didMove(toParent: self)

                // Refresh content height after layout
                DispatchQueue.main.async {
                    hobbyCardStackVC.refreshContentHeight()
                }
            }

        case .scraps:
            if let scrapGridVC = scrapGridVC {
                userProfileView.contentContainerView.addSubview(scrapGridVC.view)
                scrapGridVC.view.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(20)
                    $0.leading.trailing.bottom.equalToSuperview()
                }
                scrapGridVC.didMove(toParent: self)

                // Load scraps when first switched to scraps tab
                if viewModel.scraps.isEmpty {
                    Task { [weak self] in
                        await self?.viewModel.refreshScraps()
                    }
                } else {
                    // Refresh content height after layout
                    DispatchQueue.main.async {
                        scrapGridVC.refreshContentHeight()
                    }
                }
            }
        }
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
            guard let item = menuItem as? UserProfileMenuItem else { return }
            self?.handleMenuSelection(item)
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
        case .report:
            showReportScreen()
        case .block:
            showBlockConfirmation()
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
            guard let self = self,
                  let userId = self.viewModel.userId else { return }

            do {
                let friendsService = FriendsService()
                let response = try await friendsService.blockUser(userId: userId)

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

    private func showReportScreen() {
        guard let profile = viewModel.userProfile,
              let userId = viewModel.userId,
              let nickname = profile.nickname else { return }

        let reportVC = ReportViewController(
            targetUserId: userId,
            targetNickname: nickname
        )
        reportVC.onReportCompleted = { [weak self] (isBlocked: Bool) in
            if isBlocked {
                self?.viewModel.isBlocked = true
                self?.userProfileView.showBlockedState()
            }
        }

        navigationController?.pushViewController(reportVC, animated: true)
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
