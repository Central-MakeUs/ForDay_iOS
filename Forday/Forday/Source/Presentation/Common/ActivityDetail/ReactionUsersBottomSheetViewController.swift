//
//  ReactionUsersBottomSheetViewController.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class ReactionUsersBottomSheetViewController: UIViewController {

    // MARK: - UI Components

    private let dimmerView = UIView()
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let tabBar = ReactionTabBar()
    private let pagesScrollView = UIScrollView()
    private let pagesStackView = UIStackView()

    private var listViewControllers: [ReactionUsersListViewController] = []

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private let recordId: Int
    private var summaryResponse: ReactionSummaryResponse?
    private var hasAnimatedIn = false
    private var currentPageIndex = 0
    private var pendingTabs: [(ReactionType?, ReactionTabData)] = []

    // Sheet height states
    private let minHeight: CGFloat = 322
    private let maxHeight: CGFloat = 668
    private var currentHeight: CGFloat = 322
    private var containerHeightConstraint: Constraint?
    private lazy var sheetPanGesture = UIPanGestureRecognizer(
        target: self,
        action: #selector(handlePan(_:))
    )

    // Callback for loading more users
    var onLoadMore: ((ReactionType?, Int?) -> AnyPublisher<ReactionTabData, Error>)?

    // MARK: - Initialization

    init(recordId: Int) {
        self.recordId = recordId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupLayout()
        setupGestures()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard !hasAnimatedIn else { return }
        prepareInitialPresentationState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        buildPagesIfNeeded()

        guard !hasAnimatedIn else { return }
        hasAnimatedIn = true
        animateIn()
    }

    // MARK: - Configuration

    func configure(with response: ReactionSummaryResponse) {
        self.summaryResponse = response

        // Configure tab bar
        tabBar.configure(with: response.reactionSummary)

        clearListViewControllers()

        pendingTabs = [
            (nil, response.tabs.all),
            (.awesome, response.tabs.awesome),
            (.great, response.tabs.great),
            (.amazing, response.tabs.amazing),
            (.fighting, response.tabs.fighting)
        ]

        currentPageIndex = 0
        buildPagesIfNeeded()
    }

    private func buildPagesIfNeeded() {
        guard listViewControllers.isEmpty,
              !pendingTabs.isEmpty,
              isViewLoaded,
              view.window != nil else { return }

        listViewControllers = pendingTabs.map { type, data in
            let vc = ReactionUsersListViewController(reactionType: type)
            vc.configure(with: data)
            vc.onLoadMore = { [weak self] reactionType, lastReactionId in
                self?.loadMoreUsers(for: reactionType, lastReactionId: lastReactionId)
            }
            addListViewController(vc)
            return vc
        }

        currentPageIndex = 0
        pagesScrollView.setContentOffset(.zero, animated: false)
    }

    private func loadMoreUsers(for reactionType: ReactionType?, lastReactionId: Int?) {
        guard let onLoadMore = onLoadMore else { return }
        let index = tabIndex(for: reactionType)

        onLoadMore(reactionType, lastReactionId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        guard let self = self,
                              index < self.listViewControllers.count else { return }
                        let appError = (error as? AppError) ?? .unknown(error)
                        self.listViewControllers[index].finishLoadingMore(with: appError)
                    }
                },
                receiveValue: { [weak self] tabData in
                    guard let self = self else { return }

                    // Append new users to the corresponding list VC
                    if index < self.listViewControllers.count {
                        self.listViewControllers[index].appendUsers(
                            tabData.users,
                            lastReactionId: tabData.lastReactionId,
                            hasNext: tabData.hasNext
                        )
                    }
                }
            )
            .store(in: &cancellables)
    }

    private func tabIndex(for reactionType: ReactionType?) -> Int {
        guard let reactionType,
              let reactionIndex = [ReactionType.awesome, .great, .amazing, .fighting].firstIndex(of: reactionType) else {
            return 0
        }
        return reactionIndex + 1
    }

    private func addListViewController(_ viewController: ReactionUsersListViewController) {
        addChild(viewController)
        pagesStackView.addArrangedSubview(viewController.view)
        viewController.didMove(toParent: self)

        viewController.view.snp.makeConstraints {
            $0.width.equalTo(pagesScrollView.snp.width)
        }
    }

    private func clearListViewControllers() {
        listViewControllers.forEach { viewController in
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
        listViewControllers.removeAll()
    }

    // MARK: - Animations

    private func prepareInitialPresentationState() {
        view.layoutIfNeeded()
        dimmerView.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: minHeight)
    }

    private func animateIn() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.dimmerView.alpha = 1
            self.containerView.transform = .identity
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.dimmerView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.currentHeight)
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }

    @objc private func dimmerTapped() {
        dismiss()
    }
}

// MARK: - Setup

extension ReactionUsersBottomSheetViewController {
    private func setupStyle() {
        view.backgroundColor = .clear

        dimmerView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }

        containerView.do {
            $0.backgroundColor = .systemBackground
            $0.layer.cornerRadius = 20
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.clipsToBounds = true
        }

        titleLabel.do {
            $0.setTextWithTypography("감정 남긴 친구 목록", style: .header18)
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }

        pagesScrollView.do {
            $0.isPagingEnabled = true
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = false
            $0.delaysContentTouches = false
            $0.delegate = self
        }

        pagesStackView.do {
            $0.axis = .horizontal
            $0.spacing = 0
            $0.alignment = .fill
            $0.distribution = .fill
        }
    }

    private func setupLayout() {
        view.addSubview(dimmerView)
        view.addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(tabBar)
        containerView.addSubview(pagesScrollView)
        pagesScrollView.addSubview(pagesStackView)

        dimmerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            self.containerHeightConstraint = $0.height.equalTo(minHeight).constraint
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        tabBar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }

        pagesScrollView.snp.makeConstraints {
            $0.top.equalTo(tabBar.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-34)  // Home indicator space
        }

        pagesStackView.snp.makeConstraints {
            $0.edges.equalTo(pagesScrollView.contentLayoutGuide)
            $0.height.equalTo(pagesScrollView.frameLayoutGuide)
        }
    }

    private func setupGestures() {
        // Dimmer tap gesture
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(dimmerTapped))
        dimmerView.addGestureRecognizer(dimmerTap)

        // Pan gesture for dragging
        sheetPanGesture.cancelsTouchesInView = false
        sheetPanGesture.delegate = self
        containerView.addGestureRecognizer(sheetPanGesture)
    }

    private func setupBindings() {
        // Tab selection
        tabBar.tabSelected
            .sink { [weak self] index in
                print("🟣 [ReactionBottomSheet] tabSelected received index=\(index)")

                guard let self = self else {
                    print("🟣 [ReactionBottomSheet] ignored - self released")
                    return
                }

                self.buildPagesIfNeeded()

                guard index < self.listViewControllers.count else {
                    print("🟣 [ReactionBottomSheet] ignored - pages not ready index=\(index), count=\(self.listViewControllers.count), pending=\(self.pendingTabs.count), isViewLoaded=\(self.isViewLoaded), hasWindow=\(self.view.window != nil)")
                    return
                }

                guard index != self.currentPageIndex else {
                    print("🟣 [ReactionBottomSheet] ignored - already current index=\(index)")
                    self.tabBar.selectTab(at: index)
                    return
                }

                print("🟣 [ReactionBottomSheet] move request from=\(self.currentPageIndex) to=\(index), width=\(self.pagesScrollView.bounds.width), offsetX=\(self.pagesScrollView.contentOffset.x)")
                self.setCurrentPage(index, animated: false)
            }
            .store(in: &cancellables)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            // Update height based on drag
            let newHeight = currentHeight - translation.y
            let clampedHeight = max(minHeight, min(maxHeight, newHeight))
            currentHeight = clampedHeight
            containerHeightConstraint?.update(offset: clampedHeight)
            gesture.setTranslation(.zero, in: view)

        case .ended:
            // Snap to closest state
            let targetHeight: CGFloat
            if velocity.y < -500 {
                // Fast upward swipe -> expand
                targetHeight = maxHeight
            } else if velocity.y > 500 {
                // Fast downward swipe -> collapse or dismiss
                targetHeight = currentHeight < (minHeight + maxHeight) / 2 ? 0 : minHeight
            } else {
                // Slow drag -> snap to nearest
                let midpoint = (minHeight + maxHeight) / 2
                targetHeight = currentHeight > midpoint ? maxHeight : minHeight
            }

            if targetHeight == 0 {
                dismiss()
            } else {
                animateToHeight(targetHeight)
            }

        default:
            break
        }
    }

    private func animateToHeight(_ height: CGFloat) {
        currentHeight = height
        containerHeightConstraint?.update(offset: height)

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        }
    }

    private func setCurrentPage(_ index: Int, animated: Bool) {
        guard index >= 0,
              index < listViewControllers.count else { return }

        view.layoutIfNeeded()
        let offsetX = pagesScrollView.bounds.width * CGFloat(index)
        print("🟣 [ReactionBottomSheet] setCurrentPage index=\(index), targetOffsetX=\(offsetX), beforeOffsetX=\(pagesScrollView.contentOffset.x)")
        pagesScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
        currentPageIndex = index
        tabBar.selectTab(at: index)
        print("🟣 [ReactionBottomSheet] setCurrentPage done index=\(index), afterOffsetX=\(pagesScrollView.contentOffset.x)")
    }
}

// MARK: - UIScrollViewDelegate

extension ReactionUsersBottomSheetViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        updateSelectedTabFromScroll(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedTabFromScroll(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateSelectedTabFromScroll(scrollView)
    }

    private func updateSelectedTabFromScroll(_ scrollView: UIScrollView) {
        guard scrollView === pagesScrollView,
              scrollView.bounds.width > 0 else { return }

        let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        guard pageIndex >= 0,
              pageIndex < listViewControllers.count,
              pageIndex != currentPageIndex else { return }

        currentPageIndex = pageIndex
        tabBar.selectTab(at: pageIndex)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ReactionUsersBottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === sheetPanGesture else { return true }

        if touch.view?.isDescendant(of: tabBar) == true {
            return false
        }

        if touch.view is UIControl {
            return false
        }

        let touchPoint = touch.location(in: containerView)
        return !tabBar.frame.contains(touchPoint)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === sheetPanGesture else { return true }

        let velocity = sheetPanGesture.velocity(in: view)
        return abs(velocity.y) > abs(velocity.x)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === sheetPanGesture || otherGestureRecognizer === sheetPanGesture else {
            return false
        }

        let velocity = sheetPanGesture.velocity(in: view)
        return abs(velocity.y) > abs(velocity.x)
    }
}
