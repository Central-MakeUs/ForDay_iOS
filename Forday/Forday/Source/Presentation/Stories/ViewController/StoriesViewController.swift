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

        // Filter selection
        storiesView.filterView.onFilterSelected = { [weak self] filterType in
            Task {
                await self?.viewModel.selectFilter(filterType)
            }
        }
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
                self?.storiesView.pinterestLayout.invalidateLayout()
                self?.storiesView.collectionView.reloadData()

                if stories.isEmpty {
                    self?.storiesView.showEmptyState()
                } else {
                    self?.storiesView.hideEmptyState()
                }
            }
            .store(in: &cancellables)

        // Selected filter
        viewModel.$selectedFilterType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filterType in
                self?.storiesView.filterView.selectFilter(filterType)
            }
            .store(in: &cancellables)

        // Selected tab index
        viewModel.$selectedTabIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                self?.storiesView.tabSegmentControl.selectTab(at: index, animated: false)
            }
            .store(in: &cancellables)

        // Loading
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.storiesView.endRefreshing()
                }
            }
            .store(in: &cancellables)

        // Error handling
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error)
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

    private func handleError(_ error: AppError) {
        ToastView.showError(message: error.userMessage)
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
        // Cell width is fixed at 156
        let cellWidth: CGFloat = 156

        // Thumbnail height: min 117, max 208 based on design
        // For simplicity, use aspect ratio or fixed height
        // If has image, calculate based on image aspect ratio (estimated)
        // If gradient mode, use minimum height for thumbnail area
        let story = viewModel.stories[indexPath.item]

        // Thumbnail area height
        let thumbnailHeight: CGFloat
        if story.thumbnailUrl != nil && !story.thumbnailUrl!.isEmpty {
            // Image mode: Use proportional height (156 width, aspect ratio ~1:1.33)
            thumbnailHeight = cellWidth * 1.33
        } else {
            // Gradient mode: Use minimum height
            thumbnailHeight = 117
        }

        // Clamp thumbnail height
        let clampedThumbnailHeight = max(117, min(208, thumbnailHeight))

        // Content area: title (max 2 lines ~44pt) + user info (24pt) + spacing (8+4)
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
}

#Preview {
      let vc = StoriesViewController()
      // 목데이터로 테스트
      return vc
  } 
