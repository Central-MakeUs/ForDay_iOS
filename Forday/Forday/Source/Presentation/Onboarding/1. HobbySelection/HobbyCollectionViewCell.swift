//
//  HobbyCollectionViewCell.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//


import UIKit
import SnapKit
import Then

private class CellGradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
}

class HobbyCollectionViewCell: UICollectionViewCell {

    static let identifier = "HobbyCollectionViewCell"

    // MARK: - UI Components

    private let backgroundImageView = UIImageView()
    private let gradientView = CellGradientView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let checkmarkImageView = UIImageView()

    // Skeleton views
    private let skeletonContainerView = UIView()
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
        backgroundImageView.image = hobby.imageAsset.image
        titleLabel.setTextWithTypography(hobby.name, style: .body16)
        subtitleLabel.setTextWithTypography(hobby.description, style: .label12)
        subtitleLabel.textColor = .neutral50

        // Selected state
        if isSelected {
            contentView.layer.borderWidth = 2
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
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
        }

        backgroundImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .neutral100
        }

        gradientView.gradientLayer.do {
            $0.colors = [
                UIColor.clear.cgColor,
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(0.36).cgColor,
                UIColor.black.withAlphaComponent(0.6).cgColor
            ]
            $0.locations = [0.0, 0.50, 0.78, 1.0]
            $0.startPoint = CGPoint(x: 0.5, y: 0)
            $0.endPoint = CGPoint(x: 0.5, y: 1)
        }

        titleLabel.do {
            $0.textColor = .white
            $0.numberOfLines = 1
        }

        subtitleLabel.do {
            $0.textColor = .neutral50
            $0.numberOfLines = 2
        }

        checkmarkImageView.do {
            $0.image = .Onoff.checkboxFalse
            $0.contentMode = .scaleAspectFit
        }

        // Skeleton styles
        skeletonContainerView.do {
            $0.backgroundColor = .neutral100
            $0.isHidden = true
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
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(gradientView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(checkmarkImageView)

        // Skeleton container
        contentView.addSubview(skeletonContainerView)
        skeletonContainerView.addSubview(titleSkeleton)
        skeletonContainerView.addSubview(subtitleSkeleton)
        skeletonContainerView.addSubview(checkmarkSkeleton)

        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        gradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        checkmarkImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-11)
            $0.size.equalTo(22)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-11)
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
        }

        subtitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-11)
            $0.bottom.equalToSuperview().offset(-12)
        }

        // Skeleton layout
        skeletonContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        checkmarkSkeleton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-11)
            $0.size.equalTo(22)
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
        backgroundImageView.isHidden = true
        gradientView.isHidden = true
        titleLabel.isHidden = true
        subtitleLabel.isHidden = true
        checkmarkImageView.isHidden = true

        // Show skeleton
        skeletonContainerView.isHidden = false
        titleSkeleton.startAnimating()
        subtitleSkeleton.startAnimating()
        checkmarkSkeleton.startAnimating()
    }

    func hideSkeleton() {
        guard isSkeletonMode else { return }
        isSkeletonMode = false

        // Stop animations
        titleSkeleton.stopAnimating()
        subtitleSkeleton.stopAnimating()
        checkmarkSkeleton.stopAnimating()

        // Hide skeleton
        skeletonContainerView.isHidden = true

        // Show actual content
        backgroundImageView.isHidden = false
        gradientView.isHidden = false
        titleLabel.isHidden = false
        subtitleLabel.isHidden = false
        checkmarkImageView.isHidden = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hideSkeleton()
    }
}
