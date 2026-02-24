//
//  ImageTemplateSelectorView.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import UIKit
import SnapKit
import Then

/// 이미지 템플릿 선택 화면 뷰
final class ImageTemplateSelectorView: UIView {

    // MARK: - UI Components

    // Navigation
    private let navigationView = UIView()
    let backButton = UIButton()
    private let titleLabel = UILabel()
    let downloadButton = UIButton()

    // Header
    private let headerStackView = UIStackView()
    private let headerTitleLabel = UILabel()
    private let headerSubtitleLabel = UILabel()

    // Template Preview
    private let templateContainerView = UIView()
    let cardTemplateView = CardTemplateView()

    // Page Indicator
    private let pageIndicatorStackView = UIStackView()
    private let activeIndicator = UIView()
    private let inactiveIndicator = UIView()

    // Bottom Button
    private let bottomGradientView = UIView()
    let saveButton = UIButton()

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

    /// 템플릿 프리뷰 설정
    func configureTemplate(
        image: UIImage,
        title: String,
        date: String,
        stickerType: StickerType
    ) {
        cardTemplateView.configure(
            image: image,
            title: title,
            date: date,
            stickerType: stickerType
        )
    }
}

// MARK: - Setup

extension ImageTemplateSelectorView {
    private func style() {
        backgroundColor = .bg001

        // Navigation
        navigationView.do {
            $0.backgroundColor = .bg001
        }

        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral900
        }

        titleLabel.do {
            $0.setTextWithTypography("저장하기", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        downloadButton.do {
            $0.setImage(.Icon.download, for: .normal)
            $0.tintColor = .neutral900
        }

        // Header
        headerStackView.do {
            $0.axis = .vertical
            $0.spacing = 10
            $0.alignment = .leading
        }

        headerTitleLabel.do {
            $0.setTextWithTypography("원하는 카드 프레임을 골라주세요.", style: .header20)
            $0.textColor = .neutral900
        }

        headerSubtitleLabel.do {
            $0.setTextWithTypography("나의 활동기록을 카드로 공유할 수 있어요.", style: .label14)
            $0.textColor = .neutral800
        }

        // Template Container
        templateContainerView.do {
            $0.backgroundColor = .clear
        }

        // Page Indicator
        pageIndicatorStackView.do {
            $0.axis = .horizontal
            $0.spacing = 6
            $0.alignment = .center
        }

        activeIndicator.do {
            $0.backgroundColor = .neutral600
            $0.layer.cornerRadius = 4
        }

        inactiveIndicator.do {
            $0.backgroundColor = .neutral300
            $0.layer.cornerRadius = 4
        }

        // Bottom
        bottomGradientView.do {
            $0.backgroundColor = .clear
        }

        saveButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "저장하기"
            config.baseBackgroundColor = .action001
            config.baseForegroundColor = .neutralWhite
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 0, bottom: 19, trailing: 0)
            $0.configuration = config
        }
    }

    private func layout() {
        addSubview(navigationView)
        navigationView.addSubview(backButton)
        navigationView.addSubview(titleLabel)
        navigationView.addSubview(downloadButton)

        addSubview(headerStackView)
        headerStackView.addArrangedSubview(headerTitleLabel)
        headerStackView.addArrangedSubview(headerSubtitleLabel)

        addSubview(templateContainerView)
        templateContainerView.addSubview(cardTemplateView)

        addSubview(pageIndicatorStackView)
        pageIndicatorStackView.addArrangedSubview(activeIndicator)
        pageIndicatorStackView.addArrangedSubview(inactiveIndicator)

        addSubview(bottomGradientView)
        addSubview(saveButton)

        // Navigation
        navigationView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        downloadButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        // Header
        headerStackView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // Template Container
        templateContainerView.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(380)
        }

        cardTemplateView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        // Page Indicator
        pageIndicatorStackView.snp.makeConstraints {
            $0.top.equalTo(templateContainerView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }

        activeIndicator.snp.makeConstraints {
            $0.width.equalTo(14)
            $0.height.equalTo(8)
        }

        inactiveIndicator.snp.makeConstraints {
            $0.size.equalTo(8)
        }

        // Bottom Gradient
        bottomGradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(88)
        }

        // Save Button
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupBottomGradient()
    }

    private func setupBottomGradient() {
        // Remove existing gradient layers
        bottomGradientView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bottomGradientView.bounds
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.locations = [0.0, 0.62]
        bottomGradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("ImageTemplateSelectorView") {
    let view = ImageTemplateSelectorView()
    return view
}
#endif
