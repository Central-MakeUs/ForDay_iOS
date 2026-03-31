//
//  ScrapGridViewController.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class ScrapGridViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ProfileViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    weak var coordinator: MainTabBarCoordinator?

    // UI Components
    private let countLabel = UILabel()
    private let scrapCollectionView: UICollectionView
    private let emptyStateView = EmptyStateView()

    // Height constraint for dynamic sizing
    private var collectionViewHeightConstraint: Constraint?

    // Callback for content height change (for parent scroll adjustment)
    var onContentHeightChanged: ((CGFloat) -> Void)?

    // MARK: - Initialization

    init(viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel

        // Setup collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1

        self.scrapCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupCollectionView()
        bind()
    }
}

// MARK: - Setup

extension ScrapGridViewController {
    private func style() {
        view.backgroundColor = .systemBackground

        countLabel.do {
            $0.font = TypographyStyle.label12.font
            $0.textColor = .neutral500
            $0.text = "0개"
        }

        scrapCollectionView.do {
            $0.backgroundColor = .systemBackground
            $0.isScrollEnabled = false  // Disable scroll - parent scrollView handles it
        }
    }

    private func layout() {
        view.addSubview(countLabel)
        view.addSubview(scrapCollectionView)

        countLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }

        scrapCollectionView.snp.makeConstraints {
            $0.top.equalTo(countLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            // Store height constraint for dynamic updates
            collectionViewHeightConstraint = $0.height.equalTo(0).priority(.high).constraint
        }
    }

    private func setupCollectionView() {
        scrapCollectionView.delegate = self
        scrapCollectionView.dataSource = self
        scrapCollectionView.register(
            ActivityPhotoCell.self,
            forCellWithReuseIdentifier: ActivityPhotoCell.identifier
        )

        // Observe contentSize changes for dynamic height
        scrapCollectionView.publisher(for: \.contentSize)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] contentSize in
                self?.updateCollectionViewHeight(contentSize.height)
            }
            .store(in: &cancellables)
    }

    private func updateCollectionViewHeight(_ height: CGFloat) {
        collectionViewHeightConstraint?.update(offset: height)

        // Notify parent about height change
        // top offset(20) + countLabel(17) + spacing(8) + collectionView + bottomPadding(20)
        let totalHeight = 20 + 17 + 8 + height + 20
        onContentHeightChanged?(totalHeight)
    }

    /// Force recalculate and notify content height (called when view is re-added to parent)
    func refreshContentHeight() {
        view.layoutIfNeeded()
        scrapCollectionView.layoutIfNeeded()

        let height = scrapCollectionView.contentSize.height
        if height > 0 {
            updateCollectionViewHeight(height)
        } else {
            // If contentSize is 0, try to recalculate
            scrapCollectionView.reloadData()
            scrapCollectionView.layoutIfNeeded()
            let recalculatedHeight = scrapCollectionView.contentSize.height
            if recalculatedHeight > 0 {
                updateCollectionViewHeight(recalculatedHeight)
            }
        }
    }

    private func bind() {
        // Scraps
        viewModel.scrapsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scraps in
                self?.scrapCollectionView.reloadData()
                self?.updateEmptyState(hasScraps: !scraps.isEmpty)
            }
            .store(in: &cancellables)

        // Scrap count (totalScrapCount from server)
        viewModel.totalScrapCountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.countLabel.text = "\(count)개"
            }
            .store(in: &cancellables)
    }
}

// MARK: - Actions

extension ScrapGridViewController {
    private func updateEmptyState(hasScraps: Bool) {
        if hasScraps {
            emptyStateView.removeFromSuperview()
        } else {
            guard emptyStateView.superview == nil else { return }
            view.addSubview(emptyStateView)
            emptyStateView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(100)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(200)
            }

            emptyStateView.configureForScraps()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ScrapGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.scraps.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ActivityPhotoCell.identifier,
            for: indexPath
        ) as? ActivityPhotoCell else {
            return UICollectionViewCell()
        }

        let scrap = viewModel.scraps[indexPath.item]
        cell.configure(with: scrap)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ScrapGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let scrap = viewModel.scraps[indexPath.item]
        showActivityDetail(activityRecordId: scrap.recordId)
    }

    private func showActivityDetail(activityRecordId: Int) {
        // 부모(MyPageViewController)에게 자식 뷰로 이동함을 알림 (필터 유지용)
        (parent as? MyPageViewController)?.willNavigateToChildView()

        // Create context for paging API
        let context = ActivityDetailContext(
            contextType: .userScrap,
            userId: viewModel.userId,
            keyword: nil,
            hobbyIds: nil  // 스크랩은 취미 필터 없음
        )

        // Use PageViewController for swipe navigation
        let pageVC = ActivityDetailPageViewController(recordId: activityRecordId, context: context)
        pageVC.coordinator = coordinator

        // Push to navigation stack
        if let navController = parent?.navigationController {
            navController.pushViewController(pageVC, animated: true)
        }
    }

    /// Called by parent scrollView to trigger infinite scroll
    func checkLoadMoreIfNeeded(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        // Load more when scrolled to 80% of content
        // Prevent duplicate calls by checking isLoadingMore
        if offsetY > contentHeight - height * 1.2 && !viewModel.isLoadingMore {
            Task { [weak self] in
                await self?.viewModel.loadMoreScraps()
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ScrapGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 3
        let spacing: CGFloat = 1 // 1pt spacing between cells

        // Calculate total spacing between items (2 spacings for 3 columns)
        let totalSpacing = spacing * (numberOfColumns - 1)

        // Calculate available width (no insets - fill screen)
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / numberOfColumns)

        // Aspect ratio from Figma: 119.33 x 144.1 (height/width ≈ 1.2077)
        let itemHeight = floor(itemWidth * 144.1 / 119.33)

        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
