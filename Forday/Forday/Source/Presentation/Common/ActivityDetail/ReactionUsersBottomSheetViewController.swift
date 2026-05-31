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
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )

    private var listViewControllers: [ReactionUsersListViewController] = []

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private let recordId: Int
    private var summaryResponse: ReactionSummaryResponse?
    private var hasAnimatedIn = false

    // Sheet height states
    private let minHeight: CGFloat = 322
    private let maxHeight: CGFloat = 668
    private var currentHeight: CGFloat = 322
    private var containerHeightConstraint: Constraint?

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

        guard !hasAnimatedIn else { return }
        hasAnimatedIn = true
        animateIn()
    }

    // MARK: - Configuration

    func configure(with response: ReactionSummaryResponse) {
        self.summaryResponse = response

        // Configure tab bar
        tabBar.configure(with: response.reactionSummary)

        // Create list view controllers for each tab
        let tabs: [(ReactionType?, ReactionTabData)] = [
            (nil, response.tabs.all),
            (.awesome, response.tabs.awesome),
            (.great, response.tabs.great),
            (.amazing, response.tabs.amazing),
            (.fighting, response.tabs.fighting)
        ]

        listViewControllers = tabs.map { type, data in
            let vc = ReactionUsersListViewController(reactionType: type)
            vc.configure(with: data)
            vc.onLoadMore = { [weak self] reactionType, lastReactionId in
                self?.loadMoreUsers(for: reactionType, lastReactionId: lastReactionId)
            }
            return vc
        }

        // Set initial page
        if let firstVC = listViewControllers.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: false)
        }
    }

    private func loadMoreUsers(for reactionType: ReactionType?, lastReactionId: Int?) {
        guard let onLoadMore = onLoadMore else { return }

        onLoadMore(reactionType, lastReactionId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to load more users: \(error)")
                    }
                },
                receiveValue: { [weak self] tabData in
                    guard let self = self else { return }

                    // Find the index of the tab
                    let index: Int
                    if let type = reactionType {
                        index = [ReactionType.awesome, .great, .amazing, .fighting].firstIndex(of: type)! + 1
                    } else {
                        index = 0
                    }

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
    }

    private func setupLayout() {
        view.addSubview(dimmerView)
        view.addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(tabBar)

        addChild(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

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

        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(tabBar.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-34)  // Home indicator space
        }
    }

    private func setupGestures() {
        // Dimmer tap gesture
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(dimmerTapped))
        dimmerView.addGestureRecognizer(dimmerTap)

        // Pan gesture for dragging
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        containerView.addGestureRecognizer(panGesture)
    }

    private func setupBindings() {
        // Tab selection
        tabBar.tabSelected
            .sink { [weak self] index in
                guard let self = self,
                      index < self.listViewControllers.count,
                      let currentVC = self.pageViewController.viewControllers?.first,
                      let currentIndex = self.listViewControllers.firstIndex(of: currentVC as! ReactionUsersListViewController)
                else { return }

                let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
                let targetVC = self.listViewControllers[index]

                self.pageViewController.setViewControllers([targetVC], direction: direction, animated: true)
            }
            .store(in: &cancellables)

        // Page view controller delegate
        pageViewController.delegate = self
        pageViewController.dataSource = self
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            // Update height based on drag
            let newHeight = currentHeight - translation.y
            let clampedHeight = max(minHeight, min(maxHeight, newHeight))
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
}

// MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource

extension ReactionUsersBottomSheetViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? ReactionUsersListViewController,
              let currentIndex = listViewControllers.firstIndex(of: currentVC),
              currentIndex > 0 else {
            return nil
        }
        return listViewControllers[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? ReactionUsersListViewController,
              let currentIndex = listViewControllers.firstIndex(of: currentVC),
              currentIndex < listViewControllers.count - 1 else {
            return nil
        }
        return listViewControllers[currentIndex + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first as? ReactionUsersListViewController,
              let currentIndex = listViewControllers.firstIndex(of: currentVC) else {
            return
        }

        // Update tab bar selection
        tabBar.selectTab(at: currentIndex)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ReactionUsersBottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow pan gesture and scroll view gestures to work together
        return true
    }
}
