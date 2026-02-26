//
//  ProfileView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class ProfileView: UIView {

    // MARK: - UI Components

    private let navigationView = UIView()
    private let titleLabel = UILabel()
    let settingsButton = UIButton()

    let scrollView = UIScrollView()
    let refreshControl = UIRefreshControl()
    private let scrollContentView = UIView()

    let headerView = ProfileHeaderView()
    let segmentedControlView = ProfileSegmentedControlView()
    let contentContainerView = UIView()

    // Skeleton Views
    private let skeletonContainerView = UIView()
    private let profileImageSkeleton = SkeletonView()
    private let nicknameSkeleton = SkeletonView()
    private let stickerCountSkeleton = SkeletonView()
    private let segmentSkeleton1 = SkeletonView()
    private let segmentSkeleton2 = SkeletonView()
    private let segmentSkeleton3 = SkeletonView()
    private let contentSkeleton1 = SkeletonView()
    private let contentSkeleton2 = SkeletonView()
    private let contentSkeleton3 = SkeletonView()
    private let contentSkeleton4 = SkeletonView()
    private let contentSkeleton5 = SkeletonView()
    private let contentSkeleton6 = SkeletonView()

    // MARK: - Properties

    // Dynamic height constraint for content
    private var contentHeightConstraint: Constraint?
    private var isSkeletonVisible = false

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Setup

extension ProfileView {
    private func style() {
        backgroundColor = .systemBackground

        navigationView.do {
            $0.backgroundColor = .systemBackground
        }

        titleLabel.do {
            $0.setTextWithTypography("마이페이지", style: .header22)
            $0.textColor = .neutral900
        }

        settingsButton.do {
            $0.setImage(.Icon.settings, for: .normal)
            $0.tintColor = .neutral900
        }

        scrollView.do {
            $0.showsVerticalScrollIndicator = false
            $0.refreshControl = refreshControl
            $0.alwaysBounceVertical = true
        }

        scrollContentView.do {
            $0.backgroundColor = .systemBackground
        }

        contentContainerView.do {
            $0.backgroundColor = .systemBackground
        }

        // Skeleton styles
        skeletonContainerView.do {
            $0.backgroundColor = .systemBackground
            $0.isHidden = true
        }

        profileImageSkeleton.do {
            $0.layer.cornerRadius = 30
        }

        nicknameSkeleton.do {
            $0.layer.cornerRadius = 4
        }

        stickerCountSkeleton.do {
            $0.layer.cornerRadius = 4
        }

        [segmentSkeleton1, segmentSkeleton2, segmentSkeleton3].forEach {
            $0.layer.cornerRadius = 4
        }

        [contentSkeleton1, contentSkeleton2, contentSkeleton3,
         contentSkeleton4, contentSkeleton5, contentSkeleton6].forEach {
            $0.layer.cornerRadius = 8
        }
    }

    private func layout() {
        addSubview(navigationView)
        navigationView.addSubview(titleLabel)
        navigationView.addSubview(settingsButton)

        addSubview(scrollView)
        scrollView.addSubview(scrollContentView)

        scrollContentView.addSubview(headerView)
        scrollContentView.addSubview(segmentedControlView)
        scrollContentView.addSubview(contentContainerView)

        // Skeleton container
        scrollContentView.addSubview(skeletonContainerView)
        skeletonContainerView.addSubview(profileImageSkeleton)
        skeletonContainerView.addSubview(nicknameSkeleton)
        skeletonContainerView.addSubview(stickerCountSkeleton)
        skeletonContainerView.addSubview(segmentSkeleton1)
        skeletonContainerView.addSubview(segmentSkeleton2)
        skeletonContainerView.addSubview(segmentSkeleton3)
        skeletonContainerView.addSubview(contentSkeleton1)
        skeletonContainerView.addSubview(contentSkeleton2)
        skeletonContainerView.addSubview(contentSkeleton3)
        skeletonContainerView.addSubview(contentSkeleton4)
        skeletonContainerView.addSubview(contentSkeleton5)
        skeletonContainerView.addSubview(contentSkeleton6)

        navigationView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56).priority(.high)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        settingsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }

        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80).priority(.high)
        }

        segmentedControlView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44).priority(.high)
        }

        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(segmentedControlView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            // Dynamic height - will be updated by child content
            contentHeightConstraint = $0.height.equalTo(400).constraint
        }

        // Skeleton layout
        skeletonContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Profile header skeleton
        profileImageSkeleton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(10)
            $0.width.height.equalTo(60)
        }

        nicknameSkeleton.snp.makeConstraints {
            $0.leading.equalTo(profileImageSkeleton.snp.trailing).offset(16)
            $0.top.equalTo(profileImageSkeleton).offset(8)
            $0.width.equalTo(100)
            $0.height.equalTo(20)
        }

        stickerCountSkeleton.snp.makeConstraints {
            $0.leading.equalTo(nicknameSkeleton)
            $0.top.equalTo(nicknameSkeleton.snp.bottom).offset(8)
            $0.width.equalTo(140)
            $0.height.equalTo(16)
        }

        // Segment skeleton
        let segmentTop = 80 + 8 // header height + padding
        segmentSkeleton1.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(segmentTop)
            $0.width.equalTo(60)
            $0.height.equalTo(28)
        }

        segmentSkeleton2.snp.makeConstraints {
            $0.leading.equalTo(segmentSkeleton1.snp.trailing).offset(16)
            $0.centerY.equalTo(segmentSkeleton1)
            $0.width.equalTo(60)
            $0.height.equalTo(28)
        }

        segmentSkeleton3.snp.makeConstraints {
            $0.leading.equalTo(segmentSkeleton2.snp.trailing).offset(16)
            $0.centerY.equalTo(segmentSkeleton1)
            $0.width.equalTo(60)
            $0.height.equalTo(28)
        }

        // Content grid skeleton (2x3 grid)
        let contentTop = segmentTop + 44 + 20 // segment + padding
        let gridSpacing: CGFloat = 8
        let cellSize = (UIScreen.main.bounds.width - 40 - gridSpacing * 2) / 3

        contentSkeleton1.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(contentTop)
            $0.width.equalTo(cellSize)
            $0.height.equalTo(cellSize)
        }

        contentSkeleton2.snp.makeConstraints {
            $0.leading.equalTo(contentSkeleton1.snp.trailing).offset(gridSpacing)
            $0.top.equalTo(contentSkeleton1)
            $0.width.equalTo(cellSize)
            $0.height.equalTo(cellSize)
        }

        contentSkeleton3.snp.makeConstraints {
            $0.leading.equalTo(contentSkeleton2.snp.trailing).offset(gridSpacing)
            $0.top.equalTo(contentSkeleton1)
            $0.width.equalTo(cellSize)
            $0.height.equalTo(cellSize)
        }

        contentSkeleton4.snp.makeConstraints {
            $0.leading.equalTo(contentSkeleton1)
            $0.top.equalTo(contentSkeleton1.snp.bottom).offset(gridSpacing)
            $0.width.equalTo(cellSize)
            $0.height.equalTo(cellSize)
        }

        contentSkeleton5.snp.makeConstraints {
            $0.leading.equalTo(contentSkeleton2)
            $0.top.equalTo(contentSkeleton4)
            $0.width.equalTo(cellSize)
            $0.height.equalTo(cellSize)
        }

        contentSkeleton6.snp.makeConstraints {
            $0.leading.equalTo(contentSkeleton3)
            $0.top.equalTo(contentSkeleton4)
            $0.width.equalTo(cellSize)
            $0.height.equalTo(cellSize)
        }
    }

    /// Updates the content container height for dynamic child content
    func updateContentHeight(_ height: CGFloat) {
        // Ensure minimum height to fill screen
        let screenHeight = UIScreen.main.bounds.height
        let minHeight = screenHeight - 56 - 80 - 44 - 100 // nav + header + segment + tabbar
        let finalHeight = max(height, minHeight)
        contentHeightConstraint?.update(offset: finalHeight)
    }

    // MARK: - Skeleton

    func showSkeleton() {
        guard !isSkeletonVisible else { return }
        isSkeletonVisible = true

        // Hide actual content
        headerView.isHidden = true
        segmentedControlView.isHidden = true
        contentContainerView.isHidden = true

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
        headerView.isHidden = false
        segmentedControlView.isHidden = false
        contentContainerView.isHidden = false
    }

    private func startSkeletonAnimations() {
        profileImageSkeleton.startAnimating()
        nicknameSkeleton.startAnimating()
        stickerCountSkeleton.startAnimating()
        segmentSkeleton1.startAnimating()
        segmentSkeleton2.startAnimating()
        segmentSkeleton3.startAnimating()
        contentSkeleton1.startAnimating()
        contentSkeleton2.startAnimating()
        contentSkeleton3.startAnimating()
        contentSkeleton4.startAnimating()
        contentSkeleton5.startAnimating()
        contentSkeleton6.startAnimating()
    }

    private func stopSkeletonAnimations() {
        profileImageSkeleton.stopAnimating()
        nicknameSkeleton.stopAnimating()
        stickerCountSkeleton.stopAnimating()
        segmentSkeleton1.stopAnimating()
        segmentSkeleton2.stopAnimating()
        segmentSkeleton3.stopAnimating()
        contentSkeleton1.stopAnimating()
        contentSkeleton2.stopAnimating()
        contentSkeleton3.stopAnimating()
        contentSkeleton4.stopAnimating()
        contentSkeleton5.stopAnimating()
        contentSkeleton6.stopAnimating()
    }
}

#if DEBUG
#Preview {
    ProfileView()
}
#endif
