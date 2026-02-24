//
//  StoriesViewController.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class StoriesViewController: UIViewController {

    // MARK: - Properties

    private var storiesView: StoriesView {
        return view as! StoriesView
    }

    private let viewModel: StoriesViewModel
    private var cancellables = Set<AnyCancellable>()

    weak var coordinator: MainTabBarCoordinator?

    // MARK: - Initialization

    init(viewModel: StoriesViewModel = StoriesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = StoriesView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        setupCallbacks()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        // Load initial data on first appearance
        if viewModel.tabs.isEmpty {
            loadInitialData()
        }
    }

    // MARK: - Private Methods

    private func loadInitialData() {
        Task {
            await viewModel.loadInitialData()
        }
    }
}

// MARK: - Setup

extension StoriesViewController {
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupCollectionView() {
        storiesView.pinterestLayout.delegate = self
        storiesView.collectionView.delegate = self
        storiesView.collectionView.dataSource = self
        storiesView.configureRefreshControl(target: self, action: #selector(handleRefresh))
    }

    private func setupCallbacks() {
        // Tab selection
        storiesView.tabSegmentControl.onTabSelected = { [weak self] index, _ in
            Task {
                await self?.viewModel.selectTab(at: index)
            }
        }

        // TODO: 필터 API 완성 후 활성화
        // Filter selection
//        storiesView.filterView.onFilterSelected = { [weak self] filterType in
//            Task {
//                await self?.viewModel.selectFilter(filterType)
//            }
//        }
    }

    private func setupBindings() {
        // Tabs
        viewModel.$tabs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tabs in
                self?.storiesView.tabSegmentControl.configure(with: tabs)
                // Hide tabs if only 1 hobby
                self?.storiesView.updateTabVisibility(showTabs: tabs.count > 1)
            }
            .store(in: &cancellables)

        // Stories
        viewModel.$stories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stories in
                guard let self = self else { return }
                self.storiesView.pinterestLayout.invalidateLayout()
                self.storiesView.collectionView.reloadData()

                // 로딩 중일 때는 empty state 표시하지 않음
                if !self.viewModel.isLoading {
                    if stories.isEmpty {
                        self.storiesView.showEmptyState()
                    } else {
                        self.storiesView.hideEmptyState()
                    }
                }
            }
            .store(in: &cancellables)

        // TODO: 필터 API 완성 후 활성화
        // Selected filter
//        viewModel.$selectedFilterType
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] filterType in
//                self?.storiesView.filterView.selectFilter(filterType)
//            }
//            .store(in: &cancellables)

        // Selected tab index
        viewModel.$selectedTabIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                self?.storiesView.tabSegmentControl.selectTab(at: index, animated: false)
            }
            .store(in: &cancellables)

        // Loading - 스켈레톤 표시
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }

                if isLoading {
                    // pull-to-refresh가 아닌 경우에만 스켈레톤 표시
                    if !self.storiesView.isRefreshing {
                        // 초기 로드: 탭 + 셀 스켈레톤 / 탭 전환: 셀만 스켈레톤
                        let isInitialLoad = self.viewModel.tabs.isEmpty
                        self.storiesView.showSkeleton(includeTabs: isInitialLoad)
                    }
                } else {
                    self.storiesView.hideSkeleton()
                    self.storiesView.endRefreshing()
                    // 스켈레톤 해제 후 탭 가시성 복원
                    self.storiesView.updateTabVisibility(showTabs: self.viewModel.tabs.count > 1)
                    // 로딩 완료 후 empty state 체크
                    if self.viewModel.stories.isEmpty {
                        self.storiesView.showEmptyState()
                    } else {
                        self.storiesView.hideEmptyState()
                    }
                }
            }
            .store(in: &cancellables)

        // Error handling
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleAppError(error)
            }
            .store(in: &cancellables)

        // Image sizes updated - 이미지 크기 프리페치 완료 시 레이아웃 갱신
        viewModel.$imageSizesUpdated
            .dropFirst()  // 초기값 무시
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.storiesView.pinterestLayout.invalidateLayout()
                self?.storiesView.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Actions

extension StoriesViewController {
    @objc private func handleRefresh() {
        Task {
            await viewModel.loadStories(reset: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension StoriesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.stories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StoryCell.identifier,
            for: indexPath
        ) as? StoryCell else {
            return UICollectionViewCell()
        }

        let story = viewModel.stories[indexPath.item]
        cell.configure(with: story)
        cell.delegate = self

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension StoriesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Pagination: Load more when approaching the end
        Task {
            await viewModel.loadMoreStoriesIfNeeded(currentIndex: indexPath.item)
        }
    }
}

// MARK: - StoriesPinterestLayoutDelegate

extension StoriesViewController: StoriesPinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        // 셀 너비 (Pinterest 레이아웃에서 2열 기준)
        let insets = collectionView.contentInset
        let availableWidth = collectionView.bounds.width - (insets.left + insets.right)
        let cellWidth = availableWidth / 2 - 8  // 2열, padding 고려

        let story = viewModel.stories[indexPath.item]

        // 썸네일 영역 높이 계산
        let thumbnailHeight: CGFloat

        if let imageSize = viewModel.getImageSize(for: story), imageSize.width > 0 {
            // 캐시된 이미지 크기 기반으로 비율 계산
            let aspectRatio = imageSize.height / imageSize.width
            thumbnailHeight = cellWidth * aspectRatio
        } else if story.thumbnailUrl != nil && !story.thumbnailUrl!.isEmpty {
            // 이미지 URL은 있지만 크기가 아직 캐시되지 않은 경우 기본 비율 사용
            thumbnailHeight = cellWidth * 1.0  // 1:1 기본 비율
        } else {
            // 그라데이션 모드: memo 유무에 따라 높이 결정
            let hasMemo = story.memo != nil && !story.memo!.isEmpty
            if hasMemo {
                // memo 있음: 정방형 (1:1)
                thumbnailHeight = cellWidth
            } else {
                // memo 없음: 더 컴팩트한 비율 (156:102 ≈ 1.53:1)
                thumbnailHeight = cellWidth * 0.65
            }
        }

        // 썸네일 높이 클램프 (비율 기반)
        // min: 4:3 landscape (width * 0.75)
        // max: 3:4 portrait (width * 4/3)
        let minHeight = cellWidth * 0.75
        let maxHeight = cellWidth * (4.0 / 3.0)
        let clampedThumbnailHeight = max(minHeight, min(maxHeight, thumbnailHeight))

        // 콘텐츠 영역: 타이틀 (최대 2줄 ~44pt) + 사용자 정보 (24pt) + 간격 (8+4)
        let contentHeight: CGFloat = 8 + 44 + 4 + 24

        return clampedThumbnailHeight + contentHeight
    }
}

// MARK: - StoryCellDelegate

extension StoriesViewController: StoryCellDelegate {
    func storyCellDidTapGreatButton(_ cell: StoryCell, recordId: Int) {
        Task {
            await viewModel.toggleGreat(for: recordId)
        }
    }

    func storyCellDidTapContent(_ cell: StoryCell, recordId: Int) {
        coordinator?.showActivityDetail(activityRecordId: recordId)
    }

    func storyCellDidTapProfile(_ cell: StoryCell, userId: String) {
        coordinator?.showUserProfile(userId: userId)
    }
}

#Preview {
      let vc = StoriesViewController()
      // 목데이터로 테스트
      return vc
  } 
