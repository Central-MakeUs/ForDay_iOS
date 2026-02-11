//
//  ManageHobbyCoverView.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import SnapKit
import Then

final class ManageHobbyCoverView: UIView {

    // MARK: - UI Components

    // Custom Navigation Bar
    private let navigationBarView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    let doneButton = UIButton(type: .system)

    // Hobby List Section
    private let hobbyListContainerView = UIView()
    let hobbyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    // Feed Grid Section
    private let feedSectionContainerView = UIView()
    private let feedCountLabel = UILabel()
    let feedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    // White gradient dim at bottom
    private let bottomGradientView = UIView()

    // Empty State
    let emptyStateLabel = UILabel()

    // MARK: - Callbacks

    var onBackButtonTapped: (() -> Void)?

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

extension ManageHobbyCoverView {
    private func style() {
        backgroundColor = .systemBackground

        navigationBarView.do {
            $0.backgroundColor = .systemBackground
        }

        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral900
            $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        }

        titleLabel.do {
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }
        titleLabel.setTextWithTypography("취미 대표사진 관리", style: .header18)

        doneButton.do {
            $0.setTitleColor(.action001, for: .normal)
            $0.setTitleColor(.neutral400, for: .disabled)
            $0.isHidden = true
            $0.isEnabled = false
        }
        doneButton.setAttributedTitle(
            NSAttributedString(
                string: "완료",
                attributes: [.font: TypographyStyle.header16.font]
            ),
            for: .normal
        )

        hobbyListContainerView.do {
            $0.backgroundColor = .clear
        }

        hobbyCollectionView.do {
            $0.register(HobbyCoverCell.self, forCellWithReuseIdentifier: "HobbyCoverCell")
        }

        feedSectionContainerView.do {
            $0.backgroundColor = .clear
        }

        feedCountLabel.do {
            $0.textColor = .neutral500
        }

        feedCollectionView.do {
            $0.register(FeedItemCell.self, forCellWithReuseIdentifier: "FeedItemCell")
            $0.showsVerticalScrollIndicator = false
        }

        emptyStateLabel.do {
            $0.textColor = .neutral500
            $0.textAlignment = .center
            $0.isHidden = true
        }
    }

    private func layout() {
        // Custom Navigation Bar
        addSubview(navigationBarView)
        navigationBarView.addSubview(backButton)
        navigationBarView.addSubview(titleLabel)
        navigationBarView.addSubview(doneButton)

        addSubview(hobbyListContainerView)
        hobbyListContainerView.addSubview(hobbyCollectionView)

        addSubview(feedSectionContainerView)
        feedSectionContainerView.addSubview(feedCountLabel)
        feedSectionContainerView.addSubview(feedCollectionView)
        feedSectionContainerView.addSubview(bottomGradientView)

        addSubview(emptyStateLabel)

        // Custom Navigation Bar
        navigationBarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        doneButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        // Hobby List Container
        hobbyListContainerView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(90)
        }

        hobbyCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }

        // Feed Section Container
        feedSectionContainerView.snp.makeConstraints {
            $0.top.equalTo(hobbyListContainerView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }

        feedCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }

        // Feed Collection View (no horizontal insets - fills screen width)
        feedCollectionView.snp.makeConstraints {
            $0.top.equalTo(feedCountLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        // Bottom gradient view for white dim effect
        bottomGradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(88)
        }

        // Empty State
        emptyStateLabel.snp.makeConstraints {
            $0.center.equalTo(feedCollectionView)
        }
    }

    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.locations = [0.0, 0.62]
        gradientLayer.frame = bottomGradientView.bounds
        bottomGradientView.layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Update gradient layer frame
        if let gradientLayer = bottomGradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bottomGradientView.bounds
        } else {
            setupGradient()
        }
    }
}

// MARK: - Actions

extension ManageHobbyCoverView {
    @objc private func backButtonTapped() {
        onBackButtonTapped?()
    }
}

// MARK: - Public Methods

extension ManageHobbyCoverView {
    func updateFeedCount(_ count: Int) {
        feedCountLabel.setTextWithTypography("\(count)개", style: .label12)
    }

    func showEmptyState(_ show: Bool) {
        emptyStateLabel.setTextWithTypography("활동 기록이 없습니다", style: .label14)
        emptyStateLabel.isHidden = !show
        feedCollectionView.isHidden = show
    }

    func setDoneButtonHidden(_ hidden: Bool) {
        doneButton.isHidden = hidden
    }

    func setDoneButtonEnabled(_ enabled: Bool) {
        doneButton.isEnabled = enabled
    }
}
