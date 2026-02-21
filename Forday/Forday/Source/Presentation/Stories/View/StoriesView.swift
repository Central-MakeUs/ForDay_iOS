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

    // Header
    private let headerView = UIView()
    private let titleLabel = UILabel()
    let searchButton = UIButton()
    let notificationButton = UIButton()

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

        // Header
        headerView.do {
            $0.backgroundColor = .neutralWhite
        }

        titleLabel.do {
            $0.setTextWithTypography("소식", style: .header22)
            $0.textColor = .neutral900
        }

        searchButton.do {
            // TODO: 검색 아이콘 에셋 추가 후 활성화
            // $0.setImage(.Icon.search, for: .normal)
            $0.tintColor = .neutral500
            $0.isHidden = true
        }

        notificationButton.do {
            $0.setImage(.Icon.notificationOff, for: .normal)
            $0.tintColor = .neutral500
            $0.isHidden = true // TODO: 알림 기능 연결 시 활성화
        }

        tabSegmentControl.do {
            $0.backgroundColor = .neutralWhite
        }

        // TODO: 필터 API 완성 후 활성화
        filterView.do {
            $0.backgroundColor = .neutralWhite
            $0.isHidden = true
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
        // Header
        addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(searchButton)
        headerView.addSubview(notificationButton)

        addSubview(tabSegmentControl)
        addSubview(filterView)
        addSubview(collectionView)
        addSubview(emptyStateView)

        headerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-12)
        }

        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
            $0.width.height.equalTo(24)
        }

        // TODO: 알림 기능 연결 시 활성화 후 searchButton을 notificationButton 왼쪽으로 이동
        notificationButton.snp.makeConstraints {
            $0.trailing.equalTo(searchButton.snp.leading).offset(-12)
            $0.centerY.equalTo(titleLabel)
            $0.width.height.equalTo(24)
        }

        tabSegmentControl.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        // TODO: 필터 API 완성 후 활성화 (height: 48)
        filterView.snp.makeConstraints {
            $0.top.equalTo(tabSegmentControl.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(tabSegmentControl.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        emptyStateView.snp.makeConstraints {
            $0.center.equalTo(collectionView)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }
}
