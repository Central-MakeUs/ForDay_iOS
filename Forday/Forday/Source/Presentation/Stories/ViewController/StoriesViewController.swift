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

    // MARK: - UI Components

    private let searchBar = StoriesSearchBar()
    private let tabSegmentControl = StoriesTabSegmentControl()
    private let filterView = StoriesFilterView()

    private lazy var collectionView: UICollectionView = {
        let layout = StoriesPinterestLayout()
        layout.delegate = self
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()

    private let refreshControl = UIRefreshControl()

    // MARK: - Properties

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupCollectionView()

        // Load initial data
        Task {
            await viewModel.loadTabs()
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(searchBar)
        view.addSubview(tabSegmentControl)
        view.addSubview(filterView)
        view.addSubview(collectionView)

        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        tabSegmentControl.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        filterView.snp.makeConstraints {
            $0.top.equalTo(tabSegmentControl.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // Setup callbacks
        searchBar.onTap = { [weak self] in
            self?.handleSearchBarTapped()
        }

        tabSegmentControl.onTabSelected = { [weak self] index, tab in
            self?.viewModel.selectTab(at: index)
        }

        filterView.onFilterSelected = { [weak self] filter in
            self?.viewModel.selectFilter(filter)
        }

        refreshControl.addAction(UIAction { [weak self] _ in
            self?.handleRefresh()
        }, for: .valueChanged)
    }

    private func setupCollectionView() {
        collectionView.do {
            $0.backgroundColor = .systemBackground
            $0.register(StoryCell.self, forCellWithReuseIdentifier: StoryCell.identifier)
            $0.delegate = self
            $0.dataSource = self
            $0.refreshControl = refreshControl
            $0.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 20, right: 12)
        }
    }

    private func setupBindings() {
        // Tabs
        viewModel.$tabs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tabs in
                self?.tabSegmentControl.configure(with: tabs)
            }
            .store(in: &cancellables)

        // Stories
        viewModel.$stories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
                self?.collectionView.collectionViewLayout.invalidateLayout()
            }
            .store(in: &cancellables)

        // Loading
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
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

    // MARK: - Actions

    private func handleSearchBarTapped() {
        // TODO: Navigate to search screen (to be implemented)
        print("Search bar tapped")
    }

    private func handleRefresh() {
        Task {
            await viewModel.refresh()
        }
    }

    private func handleError(_ error: AppError) {
        let alert = UIAlertController(
            title: "오류",
            message: error.userMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
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

        cell.onReactionTapped = { [weak self] in
            self?.handleReactionTapped(for: story)
        }

        cell.onUserInfoTapped = { [weak self] in
            self?.handleUserInfoTapped(for: story)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension StoriesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let story = viewModel.stories[indexPath.item]
        coordinator?.showActivityDetail(activityRecordId: story.recordId)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Pagination: Load more when approaching the end
        let threshold = max(0, viewModel.stories.count - 5)
        if indexPath.item >= threshold {
            Task {
                await viewModel.loadMore()
            }
        }
    }
}

// MARK: - StoriesPinterestLayoutDelegate

extension StoriesViewController: StoriesPinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        // Calculate cell height based on aspect ratio
        // Cell width = (screen width - padding) / 2
        let screenWidth: CGFloat = collectionView.bounds.width
        let padding: CGFloat = 12 * 2 + 8 * 2 // left/right + column spacing
        let cellWidth: CGFloat = (screenWidth - padding) / 2

        let story = viewModel.stories[indexPath.item]

        // Image area: aspect ratio 119:128
        let imageHeight = cellWidth * (128.0 / 119.0)

        // Content area: title (max 2 lines) + user info + padding
        // Approximate: title ~40pt (2 lines) + spacing 6pt + user info 20pt + padding 16pt
        let contentHeight: CGFloat = 8 + 40 + 6 + 20 + 8

        let totalHeight = imageHeight + contentHeight

        // Clamp to min/max based on design
        let minHeight: CGFloat = 117
        let maxHeight: CGFloat = 208

        return max(minHeight, min(maxHeight, totalHeight))
    }
}

// MARK: - Cell Actions

extension StoriesViewController {
    private func handleReactionTapped(for story: Story) {
        // TODO: Implement reaction toggle using AddReactionUseCase / DeleteReactionUseCase
        print("Reaction tapped for story: \(story.recordId)")
    }

    private func handleUserInfoTapped(for story: Story) {
        coordinator?.showUserProfile(userId: story.userInfo.userId)
    }
}
