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

    private let viewModel: ProfileViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    weak var coordinator: MainTabBarCoordinator?

    // UI Components
    private let hobbyFilterView = HobbyFilterView()
    private let countLabel = UILabel()
    private let activityCollectionView: UICollectionView
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

        countLabel.do {
            $0.font = TypographyStyle.label12.font
            $0.textColor = .neutral500
            $0.text = "0개"
        }

        activityCollectionView.do {
            $0.backgroundColor = .systemBackground
            $0.isScrollEnabled = false  // Disable scroll - parent scrollView handles it
        }
    }

    private func layout() {
        view.addSubview(hobbyFilterView)
        view.addSubview(countLabel)
        view.addSubview(activityCollectionView)

        hobbyFilterView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(90)
        }

        countLabel.snp.makeConstraints {
            $0.top.equalTo(hobbyFilterView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        activityCollectionView.snp.makeConstraints {
            $0.top.equalTo(countLabel.snp.bottom).offset(8)
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
        collectionViewHeightConstraint?.update(offset: height)

        // Notify parent about height change
        // top offset(20) + hobbyFilter(90) + spacing(16) + countLabel(17) + spacing(8) + collectionView + bottomPadding(20)
        let totalHeight = 20 + 90 + 16 + 17 + 8 + height + 20
        onContentHeightChanged?(totalHeight)
    }

    /// Force recalculate and notify content height (called when view is re-added to parent)
    func refreshContentHeight() {
        view.layoutIfNeeded()
        activityCollectionView.layoutIfNeeded()

        let height = activityCollectionView.contentSize.height
        if height > 0 {
            updateCollectionViewHeight(height)
        } else {
            // If contentSize is 0, try to recalculate
            activityCollectionView.reloadData()
            activityCollectionView.layoutIfNeeded()
            let recalculatedHeight = activityCollectionView.contentSize.height
            if recalculatedHeight > 0 {
                updateCollectionViewHeight(recalculatedHeight)
            }
        }
    }

    private func setupHobbyFilter() {
        hobbyFilterView.onHobbiesSelected = { [weak self] hobbyIds in
            Task { [weak self] in
                await self?.viewModel.filterByHobbies(hobbyIds: hobbyIds)
            }
        }
    }

    private func bind() {
        // Activities
        viewModel.activitiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activities in
                self?.activityCollectionView.reloadData()
                self?.updateEmptyState(hasActivities: !activities.isEmpty)
            }
            .store(in: &cancellables)

        // Activity count (totalFeedCount from server)
        viewModel.totalActivityCountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.countLabel.text = "\(count)개"
            }
            .store(in: &cancellables)

        // Hobbies for filter
        viewModel.myHobbiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hobbies in
                self?.hobbyFilterView.configure(with: hobbies)
            }
            .store(in: &cancellables)

        // Selected hobby IDs (sync view with viewModel)
        viewModel.selectedHobbyIdsPublisher
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

            // IN_PROGRESS 상태인 취미가 있는 경우에만 버튼 표시
            let hasInProgressHobby = viewModel.myHobbies.contains { $0.status == .inProgress }
            if hasInProgressHobby {
                emptyStateView.configureForActivities { [weak self] in
                    self?.navigateToActivityRecord()
                }
            } else {
                emptyStateView.configureForActivities(onActionTapped: nil)
            }
        }
    }

    private func navigateToActivityRecord() {
        // IN_PROGRESS 상태인 취미만 활동 기록 가능
        let selectedIds = viewModel.selectedHobbyIds
        let inProgressHobbies = viewModel.myHobbies.filter { $0.status == .inProgress }

        let targetHobby: MyPageHobby?
        if !selectedIds.isEmpty {
            // 선택된 취미 중 IN_PROGRESS인 첫 번째 것
            targetHobby = inProgressHobbies.first { selectedIds.contains($0.hobbyId) }
        } else {
            // 전체 선택 상태 -> IN_PROGRESS인 첫 번째 취미
            targetHobby = inProgressHobbies.first
        }

        guard let hobby = targetHobby else {
            print("❌ IN_PROGRESS 취미 없음 - ActivityRecordViewController를 표시할 수 없습니다")
            return
        }

        coordinator?.showActivityRecord(hobbyId: hobby.hobbyId, hobbyName: hobby.hobbyName)
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
        // 부모(MyPageViewController)에게 자식 뷰로 이동함을 알림 (필터 유지용)
        (parent as? MyPageViewController)?.willNavigateToChildView()

        // Create context for paging API
        let context = ActivityDetailContext(
            contextType: .userFeed,
            userId: viewModel.userId,
            keyword: nil,
            hobbyIds: viewModel.selectedHobbyIds.isEmpty ? nil : Array(viewModel.selectedHobbyIds),
            notificationId: nil
        )

        // Coordinator를 통해 상세 화면(스와이프 모드) 표시
        coordinator?.showActivityDetailWithContext(activityRecordId: activityRecordId, context: context)
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
                await self?.viewModel.loadMoreActivities()
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
