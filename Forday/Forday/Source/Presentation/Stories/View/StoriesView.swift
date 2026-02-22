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

    // Skeleton Views
    private let skeletonContainerView = UIView()
    private let tabSkeleton1 = SkeletonView()
    private let tabSkeleton2 = SkeletonView()
    private let tabSkeleton3 = SkeletonView()
    // Grid skeletons (2 columns, varying heights)
    private let gridSkeleton1 = SkeletonView()
    private let gridSkeleton2 = SkeletonView()
    private let gridSkeleton3 = SkeletonView()
    private let gridSkeleton4 = SkeletonView()
    private let gridSkeleton5 = SkeletonView()
    private let gridSkeleton6 = SkeletonView()
    private var isSkeletonVisible = false

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

    var isRefreshing: Bool {
        return refreshControl.isRefreshing
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

    // MARK: - Skeleton

    /// 스켈레톤 표시
    /// - Parameter includeTabs: true면 탭도 스켈레톤으로 표시 (초기 로딩), false면 탭 유지 (탭 전환)
    func showSkeleton(includeTabs: Bool = true) {
        guard !isSkeletonVisible else { return }
        isSkeletonVisible = true

        // Hide actual content
        if includeTabs {
            tabSegmentControl.isHidden = true
        }
        filterView.isHidden = true
        collectionView.isHidden = true
        emptyStateView.isHidden = true

        // Show/hide tab skeletons based on includeTabs
        tabSkeleton1.isHidden = !includeTabs
        tabSkeleton2.isHidden = !includeTabs
        tabSkeleton3.isHidden = !includeTabs

        // Show skeleton
        skeletonContainerView.isHidden = false

        // Start animations
        startSkeletonAnimations()
    }

    func hideSkeleton() {
        guard isSkeletonVisible else { return }
        isSkeletonVisible = false

        // Stop animations
        stopSkeletonAnimations()

        // Hide skeleton
        skeletonContainerView.isHidden = true

        // Show actual content
        collectionView.isHidden = false
        // tabSegmentControl visibility is controlled by updateTabVisibility
        // filterView is controlled by its own logic
    }

    private func startSkeletonAnimations() {
        tabSkeleton1.startAnimating()
        tabSkeleton2.startAnimating()
        tabSkeleton3.startAnimating()
        gridSkeleton1.startAnimating()
        gridSkeleton2.startAnimating()
        gridSkeleton3.startAnimating()
        gridSkeleton4.startAnimating()
        gridSkeleton5.startAnimating()
        gridSkeleton6.startAnimating()
    }

    private func stopSkeletonAnimations() {
        tabSkeleton1.stopAnimating()
        tabSkeleton2.stopAnimating()
        tabSkeleton3.stopAnimating()
        gridSkeleton1.stopAnimating()
        gridSkeleton2.stopAnimating()
        gridSkeleton3.stopAnimating()
        gridSkeleton4.stopAnimating()
        gridSkeleton5.stopAnimating()
        gridSkeleton6.stopAnimating()
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

        // Skeleton styles
        skeletonContainerView.do {
            $0.backgroundColor = .neutralWhite
            $0.isHidden = true
        }

        [tabSkeleton1, tabSkeleton2, tabSkeleton3].forEach {
            $0.layer.cornerRadius = 4
        }

        [gridSkeleton1, gridSkeleton2, gridSkeleton3,
         gridSkeleton4, gridSkeleton5, gridSkeleton6].forEach {
            $0.layer.cornerRadius = 8
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

        // Skeleton layout
        addSubview(skeletonContainerView)
        skeletonContainerView.addSubview(tabSkeleton1)
        skeletonContainerView.addSubview(tabSkeleton2)
        skeletonContainerView.addSubview(tabSkeleton3)
        skeletonContainerView.addSubview(gridSkeleton1)
        skeletonContainerView.addSubview(gridSkeleton2)
        skeletonContainerView.addSubview(gridSkeleton3)
        skeletonContainerView.addSubview(gridSkeleton4)
        skeletonContainerView.addSubview(gridSkeleton5)
        skeletonContainerView.addSubview(gridSkeleton6)

        skeletonContainerView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // Tab skeletons
        tabSkeleton1.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(60)
            $0.height.equalTo(24)
        }

        tabSkeleton2.snp.makeConstraints {
            $0.centerY.equalTo(tabSkeleton1)
            $0.leading.equalTo(tabSkeleton1.snp.trailing).offset(16)
            $0.width.equalTo(70)
            $0.height.equalTo(24)
        }

        tabSkeleton3.snp.makeConstraints {
            $0.centerY.equalTo(tabSkeleton1)
            $0.leading.equalTo(tabSkeleton2.snp.trailing).offset(16)
            $0.width.equalTo(50)
            $0.height.equalTo(24)
        }

        // Grid skeletons (Pinterest style - 2 columns with varying heights)
        let gridTop: CGFloat = 56  // tab height + padding
        let gridSpacing: CGFloat = 8
        let gridPadding: CGFloat = 20
        let cellWidth = (UIScreen.main.bounds.width - gridPadding * 2 - gridSpacing) / 2

        // Left column
        gridSkeleton1.snp.makeConstraints {
            $0.top.equalToSuperview().offset(gridTop)
            $0.leading.equalToSuperview().offset(gridPadding)
            $0.width.equalTo(cellWidth)
            $0.height.equalTo(cellWidth * 1.2)  // Taller cell
        }

        gridSkeleton3.snp.makeConstraints {
            $0.top.equalTo(gridSkeleton1.snp.bottom).offset(gridSpacing)
            $0.leading.equalTo(gridSkeleton1)
            $0.width.equalTo(cellWidth)
            $0.height.equalTo(cellWidth * 0.9)
        }

        gridSkeleton5.snp.makeConstraints {
            $0.top.equalTo(gridSkeleton3.snp.bottom).offset(gridSpacing)
            $0.leading.equalTo(gridSkeleton1)
            $0.width.equalTo(cellWidth)
            $0.height.equalTo(cellWidth * 1.1)
        }

        // Right column
        gridSkeleton2.snp.makeConstraints {
            $0.top.equalToSuperview().offset(gridTop)
            $0.trailing.equalToSuperview().offset(-gridPadding)
            $0.width.equalTo(cellWidth)
            $0.height.equalTo(cellWidth * 0.85)  // Shorter cell
        }

        gridSkeleton4.snp.makeConstraints {
            $0.top.equalTo(gridSkeleton2.snp.bottom).offset(gridSpacing)
            $0.trailing.equalTo(gridSkeleton2)
            $0.width.equalTo(cellWidth)
            $0.height.equalTo(cellWidth * 1.3)
        }

        gridSkeleton6.snp.makeConstraints {
            $0.top.equalTo(gridSkeleton4.snp.bottom).offset(gridSpacing)
            $0.trailing.equalTo(gridSkeleton2)
            $0.width.equalTo(cellWidth)
            $0.height.equalTo(cellWidth * 0.95)
        }
    }
}
