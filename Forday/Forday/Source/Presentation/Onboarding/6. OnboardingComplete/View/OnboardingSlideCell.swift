//
//  OnboardingSlideCell.swift
//  Forday
//
//  Created by Subeen on 1/28/26.
//

import UIKit
import SnapKit
import Then

class OnboardingSlideCell: UICollectionViewCell {

    static let identifier = "OnboardingSlideCell"

    // Properties

    private let containerView = UIView()
    private let characterImageView = UIImageView()
    private var gradientLayer: CAGradientLayer?
    private var currentCharacter: IntroCharacter?

    // Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupGradientLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Configuration

    func configure(with character: IntroCharacter) {
        currentCharacter = character
        characterImageView.image = character.image

        // 테두리 색상 설정
        containerView.layer.borderColor = character.borderColor.cgColor

        // 그라디언트 색상 업데이트
        gradientLayer?.colors = [
            character.gradientStartColor.multiplyingAlpha(0.2).cgColor,
            character.gradientMediumColor.multiplyingAlpha(0.2).cgColor,
            character.gradientEndColor.multiplyingAlpha(0.2).cgColor
        ]

        // 레이아웃 강제 업데이트
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 그라디언트 레이어 크기 업데이트
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer?.frame = containerView.bounds
        CATransaction.commit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        characterImageView.image = nil
        currentCharacter = nil
        gradientLayer?.colors = nil
        containerView.layer.borderColor = UIColor.clear.cgColor
    }
}

// Setup

extension OnboardingSlideCell {
    private func style() {
        containerView.do {
            $0.layer.cornerRadius = 20
            $0.layer.borderWidth = 1
            $0.clipsToBounds = true
        }

        characterImageView.do {
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(characterImageView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 캐릭터 이미지: 정가운데 정렬 (Figma 기준 112x110)
        characterImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(112)
            $0.height.equalTo(110)
        }
    }

    private func setupGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 20
        containerView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
}
