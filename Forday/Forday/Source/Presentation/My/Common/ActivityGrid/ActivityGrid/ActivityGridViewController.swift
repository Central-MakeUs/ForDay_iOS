//
//  ActivityGridViewController.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class ActivityGridViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: MyPageViewModel
    private var cancellables = Set<AnyCancellable>()

    weak var coordinator: MainTabBarCoordinator?

    // UI Components
    private let hobbyFilterView = HobbyFilterView()
    private let activityCollectionView: UICollectionView
    private let emptyStateView = EmptyStateView()

    // Height constraint for dynamic sizing
    private var collectionViewHeightConstraint: Constraint?

    // Callback for content height change (for parent scroll adjustment)
    var onContentHeightChanged: ((CGFloat) -> Void)?

    // MARK: - Initialization

    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel

        // Setup collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1

        self.activityCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

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
        setupHobbyFilter()
        bind()
    }
}

// MARK: - Setup

extension ActivityGridViewController {
    private func style() {
        view.backgroundColor = .systemBackground

        activityCollectionView.do {
            $0.backgroundColor = .systemBackground
            $0.isScrollEnabled = false  // Disable scroll - parent scrollView handles it
        }
    }

    private func layout() {
        view.addSubview(hobbyFilterView)
        view.addSubview(activityCollectionView)

        hobbyFilterView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(90)
        }

        activityCollectionView.snp.makeConstraints {
            $0.top.equalTo(hobbyFilterView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            // Store height constraint for dynamic updates
            collectionViewHeightConstraint = $0.height.equalTo(0).priority(.high).constraint
        }
    }

    private func setupCollectionView() {
        activityCollectionView.delegate = self
        activityCollectionView.dataSource = self
        activityCollectionView.register(
            ActivityPhotoCell.self,
            forCellWithReuseIdentifier: ActivityPhotoCell.identifier
        )

        // Observe contentSize changes for dynamic height
        activityCollectionView.publisher(for: \.contentSize)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] contentSize in
                self?.updateCollectionViewHeight(contentSize.height)
            }
            .store(in: &cancellables)
    }

    private func updateCollectionViewHeight(_ height: CGFloat) {
        guard height > 0 else { return }
        collectionViewHeightConstraint?.update(offset: height)

        // Notify parent about height change (hobbyFilter height + spacing + collectionView height)
        let totalHeight = 90 + 24 + height
        onContentHeightChanged?(totalHeight)
    }

    private func setupHobbyFilter() {
        hobbyFilterView.onHobbiesSelected = { [weak self] hobbyIds in
            Task {
                await self?.viewModel.filterByHobbies(hobbyIds: hobbyIds)
            }
        }
    }

    private func bind() {
        // Activities
        viewModel.$activities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activities in
                self?.activityCollectionView.reloadData()
                self?.updateEmptyState(hasActivities: !activities.isEmpty)
            }
            .store(in: &cancellables)

        // Hobbies for filter
        viewModel.$myHobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hobbies in
                self?.hobbyFilterView.configure(with: hobbies)
            }
            .store(in: &cancellables)

        // Selected hobby IDs (sync view with viewModel)
        viewModel.$selectedHobbyIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedIds in
                self?.hobbyFilterView.selectHobbies(selectedIds)
            }
            .store(in: &cancellables)

    }
}

// MARK: - Actions

extension ActivityGridViewController {
    private func updateEmptyState(hasActivities: Bool) {
        if hasActivities {
            emptyStateView.removeFromSuperview()
        } else {
            view.addSubview(emptyStateView)
            emptyStateView.snp.makeConstraints {
                $0.top.equalTo(hobbyFilterView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }

            emptyStateView.configureForActivities { [weak self] in
                self?.navigateToActivityRecord()
            }
        }
    }

    private func navigateToActivityRecord() {
        coordinator?.showActivityRecord()
    }
}

// MARK: - UICollectionViewDataSource

extension ActivityGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.activities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ActivityPhotoCell.identifier,
            for: indexPath
        ) as? ActivityPhotoCell else {
            return UICollectionViewCell()
        }

        let activity = viewModel.activities[indexPath.item]
        cell.configure(with: activity)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ActivityGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activity = viewModel.activities[indexPath.item]
        showActivityDetail(activityRecordId: activity.recordId)
    }

    private func showActivityDetail(activityRecordId: Int) {
        let detailViewModel = ActivityDetailViewModel(activityRecordId: activityRecordId)
        let detailVC = ActivityDetailViewController(viewModel: detailViewModel)
        detailVC.coordinator = coordinator

        // Push to navigation stack
        if let navController = parent?.navigationController {
            navController.pushViewController(detailVC, animated: true)
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
            Task {
                await viewModel.loadMoreActivities()
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ActivityGridViewController: UICollectionViewDelegateFlowLayout {
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

#Preview {
    MyPageViewController()
}
