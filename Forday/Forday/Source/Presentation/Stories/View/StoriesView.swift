//
//  StoriesView.swift
//  Forday
//
//  Created by Subeen on 2/19/26.
//

import UIKit
import SnapKit
import Then

final class StoriesView: UIView {

    // MARK: - UI Components

    let tabSegmentControl = StoriesTabSegmentControl()
    let filterView = StoriesFilterView()
    let collectionView: UICollectionView

    private let refreshControl = UIRefreshControl()

    // Pinterest Layout
    let pinterestLayout = StoriesPinterestLayout()

    // Empty state view
    private let emptyStateView = EmptyStateView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: pinterestLayout)
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func configureRefreshControl(target: Any?, action: Selector) {
        refreshControl.addTarget(target, action: action, for: .valueChanged)
    }

    func endRefreshing() {
        refreshControl.endRefreshing()
    }

    func showEmptyState(message: String = "아직 등록된 소식이 없어요") {
        emptyStateView.configure(icon: .Icon.emptyBox, message: message, actionTitle: nil)
        emptyStateView.isHidden = false
        collectionView.isHidden = true
    }

    func hideEmptyState() {
        emptyStateView.isHidden = true
        collectionView.isHidden = false
    }

    func updateTabVisibility(showTabs: Bool) {
        tabSegmentControl.isHidden = !showTabs
        tabSegmentControl.snp.updateConstraints {
            $0.height.equalTo(showTabs ? 44 : 0)
        }
    }
}

// MARK: - Setup

extension StoriesView {
    private func style() {
        backgroundColor = .neutralWhite

        tabSegmentControl.do {
            $0.backgroundColor = .neutralWhite
        }

        filterView.do {
            $0.backgroundColor = .neutralWhite
        }

        collectionView.do {
            $0.backgroundColor = .neutralWhite
            $0.showsVerticalScrollIndicator = false
            $0.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 20, right: 20)
            $0.refreshControl = refreshControl
            $0.register(StoryCell.self, forCellWithReuseIdentifier: StoryCell.identifier)
        }

        emptyStateView.do {
            $0.isHidden = true
        }
    }

    private func layout() {
        addSubview(tabSegmentControl)
        addSubview(filterView)
        addSubview(collectionView)
        addSubview(emptyStateView)

        tabSegmentControl.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        filterView.snp.makeConstraints {
            $0.top.equalTo(tabSegmentControl.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        emptyStateView.snp.makeConstraints {
            $0.center.equalTo(collectionView)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }
}
