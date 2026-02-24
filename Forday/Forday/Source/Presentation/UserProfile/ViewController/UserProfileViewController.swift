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

        Task {
            await viewModel.fetchInitialData()

            await MainActor.run {
                userProfileView.hideSkeleton()

                if isFirstLoad {
                    setupChildViewControllers()
                    switchToTab(.activities)
                    isFirstLoad = false
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
                self?.userProfileView.setTitle(profile.nickname)
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
            }

        case .hobbyCards:
            if let hobbyCardStackVC = hobbyCardStackVC {
                userProfileView.contentContainerView.addSubview(hobbyCardStackVC.view)
                hobbyCardStackVC.view.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
                hobbyCardStackVC.didMove(toParent: self)
            }

        case .scraps:
            if let scrapGridVC = scrapGridVC {
                userProfileView.contentContainerView.addSubview(scrapGridVC.view)
                scrapGridVC.view.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(20)
                    $0.leading.trailing.bottom.equalToSuperview()
                }
                scrapGridVC.didMove(toParent: self)
            }
        }
    }
}

// MARK: - Actions

extension UserProfileViewController {
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func moreButtonTapped() {
        if dropdownView != nil {
            dismissDropdown()
        } else {
            showDropdown()
        }
    }

    @objc private func refreshData() {
        Task {
            await viewModel.fetchInitialData()

            await MainActor.run {
                userProfileView.refreshControl.endRefreshing()
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
        let alert = UIAlertController(
            title: "차단하기",
            message: "이 사용자를 차단하시겠습니까?\n차단된 사용자의 게시물은 더 이상 표시되지 않습니다.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "차단", style: .destructive) { [weak self] _ in
            self?.performBlock()
        })

        present(alert, animated: true)
    }

    private func performBlock() {
        // TODO: 차단 API 호출
        ToastView.show(message: "사용자를 차단했습니다")
        dismiss(animated: true)
    }

    private func showReportOptions() {
        let alert = UIAlertController(
            title: "신고하기",
            message: "이 사용자를 신고하시겠습니까?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "신고", style: .destructive) { [weak self] _ in
            self?.performReport()
        })

        present(alert, animated: true)
    }

    private func performReport() {
        // TODO: 신고 API 호출
        ToastView.show(message: "신고가 접수되었습니다")
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
