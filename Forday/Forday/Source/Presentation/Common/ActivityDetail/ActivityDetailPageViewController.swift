//
//  ActivityDetailPageViewController.swift
//  Forday
//
//  Created by Subeen on 3/31/26.
//

import UIKit
import SnapKit
import Then
import Combine

/// 활동 기록 상세 화면 페이징 컨테이너
/// 인스타그램 스타일의 세로 스와이프로 이전/다음 기록 탐색
final class ActivityDetailPageViewController: UIViewController {

    // MARK: - Properties

    private let pageViewController: UIPageViewController
    private var currentRecordId: Int
    private let context: ActivityDetailContext

    weak var coordinator: MainTabBarCoordinator?

    // 현재 표시 중인 DetailViewController
    private var currentDetailVC: ActivityDetailViewController? {
        didSet {
            bindCurrentDetail()
        }
    }

    // UI Components - Navigation
    private let navigationView = UIView()
    private let navigationTitleLabel = UILabel()
    private let backButton = UIButton()
    private let saveButton = UIButton()
    private let moreButton = UIButton()

    // UI Components - Bottom
    private let reactionButtonsView = ReactionButtonsView()

    private var cancellables = Set<AnyCancellable>()
    private var childCancellables = Set<AnyCancellable>()
    private var isLoadingReactionUsersBottomSheet = false

    private enum PagingDirection {
        case previous
        case next

        var pageDirection: UIPageViewController.NavigationDirection {
            switch self {
            case .previous:
                return .reverse
            case .next:
                return .forward
            }
        }
    }

    // PageViewController의 내부 scrollView (제스처 제어용)
    private var pageScrollView: UIScrollView? {
        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }

    // 로딩 인디케이터 (위/아래)
    private let topLoadingIndicator = UIActivityIndicatorView(style: .medium)
    private let bottomLoadingIndicator = UIActivityIndicatorView(style: .medium)

    private let pagingTriggerThreshold: CGFloat = 80
    private let edgePagingActivationInset: CGFloat = 120
    private var lockedPagingDirection: PagingDirection?

    // 페이징 전환 중 플래그 (제스처 충돌 방지용)
    private var isTransitioning = false

    private lazy var edgePagingPanGesture = UIPanGestureRecognizer(
        target: self,
        action: #selector(handleEdgePagingPan(_:))
    )

    // MARK: - Initialization

    init(recordId: Int, context: ActivityDetailContext) {
        self.currentRecordId = recordId
        self.context = context

        // UIPageViewController 설정 (세로 방향)
        self.pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: nil
        )

        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        setupLoadingIndicators()
        setupNavigationView()
        setupReactionViews()
        setupEdgePagingGesture()
        loadInitialViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Setup

extension ActivityDetailPageViewController {
    private func setupPageViewController() {
        // PageViewController를 자식으로 추가
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)

        pageViewController.delegate = self

        // 배경색
        view.backgroundColor = .systemBackground
        pageViewController.view.backgroundColor = .systemBackground

        // 상세 콘텐츠 스크롤을 우선하고, 경계에서만 직접 페이징합니다.
        pageScrollView?.isScrollEnabled = false
    }

    private func setupEdgePagingGesture() {
        edgePagingPanGesture.delegate = self
        edgePagingPanGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(edgePagingPanGesture)
    }

    private func setupLoadingIndicators() {
        // 위쪽 로딩 인디케이터
        view.addSubview(topLoadingIndicator)
        topLoadingIndicator.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(76)
            $0.centerX.equalToSuperview()
        }
        topLoadingIndicator.hidesWhenStopped = true

        // 아래쪽 로딩 인디케이터
        view.addSubview(bottomLoadingIndicator)
        bottomLoadingIndicator.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-92)
            $0.centerX.equalToSuperview()
        }
        bottomLoadingIndicator.hidesWhenStopped = true
    }

    private func setupNavigationView() {
        view.addSubview(navigationView)
        navigationView.addSubview(backButton)
        navigationView.addSubview(saveButton)
        navigationView.addSubview(moreButton)
        navigationView.addSubview(navigationTitleLabel)

        navigationView.do {
            $0.backgroundColor = .systemBackground
        }

        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral900
            $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        }

        moreButton.do {
            $0.setImage(.Icon.threeDotVertical, for: .normal)
            $0.tintColor = .neutral900
            $0.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        }

        saveButton.do {
            $0.setImage(.Icon.save, for: .normal)
            $0.tintColor = .neutral900
            $0.isHidden = true
            $0.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        }

        navigationTitleLabel.do {
            $0.setTextWithTypography("내 활동 보기", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
            $0.isHidden = true
        }

        navigationView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-16)
            $0.width.height.equalTo(24)
        }

        saveButton.snp.makeConstraints {
            $0.trailing.equalTo(moreButton.snp.leading).offset(-16)
            $0.centerY.equalTo(backButton)
            $0.width.height.equalTo(24)
        }

        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(backButton)
            $0.width.height.equalTo(24)
        }

        navigationTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
    }

    private func setupReactionViews() {
        view.addSubview(reactionButtonsView)

        reactionButtonsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(72)
        }

        // 반응 버튼 이벤트 연결
        reactionButtonsView.reactionSingleTapped
            .sink { [weak self] type in
                Task {
                    await self?.currentDetailVC?.viewModel.toggleReaction(type)
                }
            }
            .store(in: &cancellables)

        reactionButtonsView.reactionLongPressed
            .sink { [weak self] type in
                self?.handleReactionLongPressed(type)
            }
            .store(in: &cancellables)

        reactionButtonsView.bookmarkTapped
            .sink { [weak self] in
                Task {
                    await self?.currentDetailVC?.viewModel.toggleScrap()
                }
            }
            .store(in: &cancellables)
    }

    private func bindCurrentDetail() {
        childCancellables.removeAll()

        // 이전 기록의 UI 상태 초기화
        saveButton.isHidden = true

        guard let detailVC = currentDetailVC else { return }

        // 상세 정보 갱신 감지하여 UI 업데이트
        detailVC.viewModel.$activityDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                guard let self = self, let detail = detail else { return }
                self.updateNavigationState(with: detail)
                self.reactionButtonsView.configure(with: detail)
            }
            .store(in: &childCancellables)
    }

    private func updateNavigationState(with detail: ActivityDetail) {
        let hasImage = !detail.imageUrl.isEmpty
        saveButton.isHidden = !(detail.recordOwner && hasImage)
        navigationTitleLabel.isHidden = true
        backButton.isHidden = false
        moreButton.isHidden = false
    }

    private func loadInitialViewController() {
        let detailVC = createDetailViewController(for: currentRecordId)
        currentDetailVC = detailVC

        pageViewController.setViewControllers(
            [detailVC],
            direction: .forward,
            animated: false
        )
    }
}

// MARK: - Actions

extension ActivityDetailPageViewController {
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func moreButtonTapped() {
        currentDetailVC?.handleMoreButtonTapped(sourceView: moreButton)
    }

    @objc private func saveButtonTapped() {
        currentDetailVC?.handleSaveButtonTapped()
    }

    private func handleReactionLongPressed(_ reactionType: ReactionType) {
        guard !isLoadingReactionUsersBottomSheet,
              !(presentedViewController is ReactionUsersBottomSheetViewController) else {
            return
        }

        isLoadingReactionUsersBottomSheet = true

        Task { [weak self] in
            guard let self = self else { return }
            defer {
                Task { @MainActor [weak self] in
                    self?.isLoadingReactionUsersBottomSheet = false
                }
            }
            guard let currentDetailVC = self.currentDetailVC else { return }

            do {
                // Fetch reaction summary
                let summary = try await currentDetailVC.viewModel.fetchReactionSummary()

                await MainActor.run {
                    // Create and present bottom sheet
                    let bottomSheet = ReactionUsersBottomSheetViewController(recordId: currentDetailVC.viewModel.activityRecordId)
                    bottomSheet.configure(with: summary)

                    // Setup pagination callback
                    bottomSheet.onLoadMore = { [weak currentDetailVC] reactionType, lastReactionId in
                        guard let currentDetailVC = currentDetailVC else {
                            return Fail(error: AppError.unknown(NSError(domain: "ViewModel", code: -1)))
                                .eraseToAnyPublisher()
                        }
                        return currentDetailVC.viewModel.fetchMoreReactionUsers(
                            for: reactionType,
                            lastReactionId: lastReactionId
                        )
                    }

                    self.present(bottomSheet, animated: false)
                }
            } catch let appError as AppError {
                await MainActor.run {
                    currentDetailVC.viewModel.error = appError
                }
            } catch {
                await MainActor.run {
                    currentDetailVC.viewModel.error = .unknown(error)
                }
            }
        }
    }

    @objc private func handleEdgePagingPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            lockedPagingDirection = pagingDirection(for: gesture)

        case .changed:
            if lockedPagingDirection == nil {
                lockedPagingDirection = pagingDirection(for: gesture)
            }

            guard let direction = lockedPagingDirection,
                  !isTransitioning,
                  canPage(direction) else { return }

            let translationY = gesture.translation(in: view).y
            let passedThreshold: Bool

            switch direction {
            case .previous:
                passedThreshold = translationY >= pagingTriggerThreshold
            case .next:
                passedThreshold = translationY <= -pagingTriggerThreshold
            }

            if passedThreshold {
                performPageTransition(direction)
            }

        case .ended, .cancelled, .failed:
            if !isTransitioning {
                lockedPagingDirection = nil
            }

        default:
            break
        }
    }
}

// MARK: - ViewController Creation

extension ActivityDetailPageViewController {
    private func createDetailViewController(for recordId: Int) -> ActivityDetailViewController {
        let viewModel = ActivityDetailViewModel(activityRecordId: recordId, context: context)
        let detailVC = ActivityDetailViewController(viewModel: viewModel, isPagingMode: true)
        detailVC.coordinator = coordinator

        return detailVC
    }

    private func targetRecordId(for direction: PagingDirection) -> Int? {
        switch direction {
        case .previous:
            return currentDetailVC?.viewModel.prevRecordId
        case .next:
            return currentDetailVC?.viewModel.nextRecordId
        }
    }

    private func canPage(_ direction: PagingDirection) -> Bool {
        guard let currentDetailVC = currentDetailVC,
              targetRecordId(for: direction) != nil else { return false }

        switch direction {
        case .previous:
            return currentDetailVC.canPageToPrevious
        case .next:
            return currentDetailVC.canPageToNext
        }
    }

    private func canBeginPagingGesture(
        _ gesture: UIPanGestureRecognizer,
        direction: PagingDirection
    ) -> Bool {
        guard canPage(direction) else { return false }

        let locationY = gesture.location(in: view).y
        let safeTop = view.safeAreaInsets.top
        let safeBottomStart = view.bounds.height - view.safeAreaInsets.bottom

        switch direction {
        case .previous:
            guard locationY <= safeTop + edgePagingActivationInset else { return false }
        case .next:
            guard locationY >= safeBottomStart - edgePagingActivationInset else { return false }
        }

        return true
    }

    private func pagingDirection(for gesture: UIPanGestureRecognizer) -> PagingDirection? {
        let velocity = gesture.velocity(in: view)
        guard abs(velocity.y) > abs(velocity.x) else { return nil }

        if velocity.y > 0 {
            return .previous
        } else if velocity.y < 0 {
            return .next
        }

        return nil
    }

    private func performPageTransition(_ direction: PagingDirection) {
        guard !isTransitioning,
              canPage(direction),
              let targetRecordId = targetRecordId(for: direction) else { return }

        isTransitioning = true
        lockedPagingDirection = direction
        setLoadingIndicatorVisible(true, for: direction)

        let nextDetailVC = createDetailViewController(for: targetRecordId)

        pageViewController.setViewControllers(
            [nextDetailVC],
            direction: direction.pageDirection,
            animated: true
        ) { [weak self, weak nextDetailVC] completed in
            guard let self = self else { return }

            if completed, let nextDetailVC = nextDetailVC {
                self.currentDetailVC = nextDetailVC
                self.currentRecordId = nextDetailVC.viewModel.activityRecordId
            }

            self.setLoadingIndicatorVisible(false, for: direction)
            self.isTransitioning = false
            self.lockedPagingDirection = nil
        }
    }

    private func setLoadingIndicatorVisible(_ visible: Bool, for direction: PagingDirection) {
        let activeIndicator: UIActivityIndicatorView
        let inactiveIndicator: UIActivityIndicatorView

        switch direction {
        case .previous:
            activeIndicator = topLoadingIndicator
            inactiveIndicator = bottomLoadingIndicator
        case .next:
            activeIndicator = bottomLoadingIndicator
            inactiveIndicator = topLoadingIndicator
        }

        inactiveIndicator.stopAnimating()

        if visible {
            activeIndicator.startAnimating()
        } else {
            activeIndicator.stopAnimating()
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension ActivityDetailPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let detailVC = viewController as? ActivityDetailViewController,
              let prevRecordId = detailVC.viewModel.prevRecordId else {
            return nil
        }

        return createDetailViewController(for: prevRecordId)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let detailVC = viewController as? ActivityDetailViewController,
              let nextRecordId = detailVC.viewModel.nextRecordId else {
            return nil
        }

        return createDetailViewController(for: nextRecordId)
    }
}

// MARK: - UIPageViewControllerDelegate

extension ActivityDetailPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]) {
        // Interactive paging is disabled. Programmatic transitions are handled by performPageTransition(_:).
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
        // Interactive paging is disabled. Programmatic transitions are handled by performPageTransition(_:).
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ActivityDetailPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === edgePagingPanGesture else { return true }
        guard !isTransitioning,
              let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
              let direction = pagingDirection(for: panGesture) else { return false }

        return canBeginPagingGesture(panGesture, direction: direction)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return gestureRecognizer === edgePagingPanGesture
    }
}
