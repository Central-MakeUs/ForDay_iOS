//
//  SimpleHobbySelectionView.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//

import UIKit
import SnapKit
import Then

class SimpleHobbySelectionView: UIView {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    let characterImageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    let collectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // MARK: - Properties

    private var collectionViewHeightConstraint: Constraint?

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

extension SimpleHobbySelectionView {
    private func style() {
        backgroundColor = .bg002

        scrollView.do {
            $0.showsVerticalScrollIndicator = false
        }

        characterImageView.do {
            $0.image = .Hobbyicon.default
            $0.contentMode = .scaleAspectFit
        }

        titleLabel.do {
            $0.setTextWithTypography("유지 님,\n어떤 취미를 시작하고 싶으세요?", style: .header20)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            $0.setTextWithTypography("마음에 드는 취미를 선택해주세요.", style: .label14)
            $0.textColor = .neutral800
            $0.numberOfLines = 0
        }

        collectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.isScrollEnabled = false
            $0.register(HobbyChipCollectionViewCell.self, forCellWithReuseIdentifier: HobbyChipCollectionViewCell.identifier)
        }
    }

    private func layout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(characterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(collectionView)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-88)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        characterImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(56)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(characterImageView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            collectionViewHeightConstraint = $0.height.equalTo(200).constraint
            $0.bottom.equalToSuperview().offset(-24)
        }
    }
}

// MARK: - Public Methods

extension SimpleHobbySelectionView {
    func updateCollectionViewHeight() {
        layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeightConstraint?.update(offset: contentHeight)
        layoutIfNeeded()
    }

    func updateTitleLabel(nickname: String) {
        titleLabel.setTextWithTypography("\(nickname) 님,\n어떤 취미를 시작하고 싶으세요?", style: .header20)
    }
}

// MARK: - LeftAlignedCollectionViewFlowLayout

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0

        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }

        return attributes
    }
}
