//
//  HobbyCollectionViewCell.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//


import UIKit
import SnapKit
import Then

class HobbyCollectionViewCell: UICollectionViewCell {

    static let identifier = "HobbyCollectionViewCell"

    // MARK: - UI Components

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let checkmarkImageView = UIImageView()

    // Skeleton views
    private let skeletonContainerView = UIView()
    private let iconSkeleton = SkeletonView()
    private let titleSkeleton = SkeletonView()
    private let subtitleSkeleton = SkeletonView()
    private let checkmarkSkeleton = SkeletonView()

    // MARK: - Properties

    private var isSkeletonMode = false

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with hobby: HobbyCard, isSelected: Bool) {
        iconImageView.image = hobby.imageAsset.hobbySelectionIcon
        titleLabel.setTextWithTypography(hobby.name, style: .body16)
        subtitleLabel.setTextWithTypography(hobby.description, style: .label12)
        subtitleLabel.textColor = .neutral700

        // Selected state
        if isSelected {
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.action001.cgColor
            checkmarkImageView.image = .Onoff.checkboxTrue
        } else {
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.stroke001.cgColor
            checkmarkImageView.image = .Onoff.checkboxFalse
        }
    }
}

// MARK: - Setup

extension HobbyCollectionViewCell {
    private func style() {
        contentView.do {
            $0.backgroundColor = .clear
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
        }

        iconImageView.do {
            $0.contentMode = .scaleAspectFit
        }

        titleLabel.do {
            $0.textColor = .neutral900
            $0.numberOfLines = 1
        }

        subtitleLabel.do {
            $0.textColor = .neutral700
            $0.numberOfLines = 2
        }

        checkmarkImageView.do {
            $0.image = .Onoff.radioFalse
            $0.contentMode = .scaleAspectFit
        }

        // Skeleton styles
        skeletonContainerView.do {
            $0.backgroundColor = .neutral100
            $0.isHidden = true
        }

        iconSkeleton.do {
            $0.layer.cornerRadius = 8
        }

        titleSkeleton.do {
            $0.layer.cornerRadius = 4
        }

        subtitleSkeleton.do {
            $0.layer.cornerRadius = 4
        }

        checkmarkSkeleton.do {
            $0.layer.cornerRadius = 4
        }
    }

    private func layout() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(checkmarkImageView)

        // Skeleton container
        contentView.addSubview(skeletonContainerView)
        skeletonContainerView.addSubview(iconSkeleton)
        skeletonContainerView.addSubview(titleSkeleton)
        skeletonContainerView.addSubview(subtitleSkeleton)
        skeletonContainerView.addSubview(checkmarkSkeleton)

        // 아이콘: 상단 중앙, 60x60
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(31)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(60)
        }

        checkmarkImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-11)
            $0.size.equalTo(20)
        }

        // 타이틀: 하단 좌측
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-9)
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
        }

        // 서브타이틀: 타이틀 아래
        subtitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-9)
            $0.bottom.equalToSuperview().offset(-12)
        }

        // Skeleton layout
        skeletonContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconSkeleton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(31)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(60)
        }

        checkmarkSkeleton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-11)
            $0.size.equalTo(20)
        }

        titleSkeleton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-40)
            $0.bottom.equalTo(subtitleSkeleton.snp.top).offset(-8)
            $0.height.equalTo(18)
        }

        subtitleSkeleton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.equalTo(14)
        }
    }
}

// MARK: - Skeleton

extension HobbyCollectionViewCell {
    func showSkeleton() {
        guard !isSkeletonMode else { return }
        isSkeletonMode = true

        // Hide actual content
        iconImageView.isHidden = true
        titleLabel.isHidden = true
        subtitleLabel.isHidden = true
        checkmarkImageView.isHidden = true

        // Show skeleton
        skeletonContainerView.isHidden = false
        iconSkeleton.startAnimating()
        titleSkeleton.startAnimating()
        subtitleSkeleton.startAnimating()
        checkmarkSkeleton.startAnimating()
    }

    func hideSkeleton() {
        guard isSkeletonMode else { return }
        isSkeletonMode = false

        // Stop animations
        iconSkeleton.stopAnimating()
        titleSkeleton.stopAnimating()
        subtitleSkeleton.stopAnimating()
        checkmarkSkeleton.stopAnimating()

        // Hide skeleton
        skeletonContainerView.isHidden = true

        // Show actual content
        iconImageView.isHidden = false
        titleLabel.isHidden = false
        subtitleLabel.isHidden = false
        checkmarkImageView.isHidden = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hideSkeleton()
    }
}
