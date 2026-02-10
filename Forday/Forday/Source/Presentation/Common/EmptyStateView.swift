//
//  EmptyStateView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class EmptyStateView: UIView {

    // MARK: - UI Components

    private let iconImageView = UIImageView()
    private let messageContainerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton()

    // MARK: - Properties

    var onActionTapped: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// Legacy configure method for backward compatibility
    func configure(icon: UIImage?, message: String, actionTitle: String? = nil) {
        onActionTapped = nil // 이전 클로저 초기화
        iconImageView.image = icon
        iconImageView.alpha = 1.0
        titleLabel.setTextWithTypography(message, style: .header16)
        subtitleLabel.isHidden = true

        if let actionTitle = actionTitle {
            var config = actionButton.configuration
            var attributedTitle = AttributedString(actionTitle)
            attributedTitle.font = TypographyStyle.label12.font
            config?.attributedTitle = attributedTitle
            actionButton.configuration = config
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }

    /// New configure method for activities empty state
    func configureForActivities(onActionTapped: (() -> Void)? = nil) {
        iconImageView.image = .Icon.emptyBox
        iconImageView.alpha = 0.4
        titleLabel.setTextWithTypography("활동을 기록해보세요!", style: .header16)
        subtitleLabel.setTextWithTypography("당신의 활동기록이 궁금해요.", style: .label14)
        subtitleLabel.isHidden = false

        var config = actionButton.configuration
        var attributedTitle = AttributedString("활동 기록하러가기")
        attributedTitle.font = TypographyStyle.label12.font
        config?.attributedTitle = attributedTitle
        actionButton.configuration = config
        actionButton.isHidden = false

        self.onActionTapped = onActionTapped
    }

    /// Configure for hobby cards empty state
    func configureForHobbyCards() {
        iconImageView.image = .Icon.emptyBox
        iconImageView.alpha = 0.4
        titleLabel.setTextWithTypography("취미카드를 준비 중이에요.", style: .header16)
        subtitleLabel.setTextWithTypography("지금 하고 있는 취미를\n꾸준히 이어가 보세요!", style: .label14)
        subtitleLabel.isHidden = false
        actionButton.isHidden = true
        self.onActionTapped = nil
    }

    /// Configure for scraps empty state
    func configureForScraps() {
        iconImageView.image = .Icon.emptyBox
        iconImageView.alpha = 0.4
        titleLabel.setTextWithTypography("아직 스크랩한 기록이 없어요.", style: .header16)
        subtitleLabel.setTextWithTypography("마음에 드는 취미활동을 둘러볼까요?", style: .label14)
        subtitleLabel.isHidden = false
        actionButton.isHidden = true
        self.onActionTapped = nil
    }
}

// MARK: - Setup

extension EmptyStateView {
    private func style() {
        backgroundColor = .systemBackground

        iconImageView.do {
            $0.contentMode = .scaleAspectFit
        }

        messageContainerView.do {
            $0.backgroundColor = .clear
        }

        titleLabel.do {
            $0.textColor = .neutral900
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            $0.textColor = .neutral600
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.isHidden = true
        }

        actionButton.do {
            var config = UIButton.Configuration.filled()
            config.background.cornerRadius = 6
            config.cornerStyle = .fixed
            config.baseBackgroundColor = .action001
            config.baseForegroundColor = .white
            config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
            $0.configuration = config
            $0.isHidden = true
        }
    }

    private func layout() {
        // emptyBox 이미지가 맨 뒤에 깔림
        addSubview(iconImageView)
        // 메시지 컨테이너가 이미지 위에 위치
        addSubview(messageContainerView)
        messageContainerView.addSubview(titleLabel)
        messageContainerView.addSubview(subtitleLabel)
        messageContainerView.addSubview(actionButton)

        // emptyBox 이미지: 160x140, 상단 중앙
        iconImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.width.equalTo(160)
            $0.height.equalTo(140)
        }

        // 메시지 컨테이너: 이미지와 겹치도록 배치 (이미지 top + 77pt)
        messageContainerView.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.top).offset(77)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }

        actionButton.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(28)
            $0.bottom.equalToSuperview()
        }
    }

    private func setupActions() {
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Actions

extension EmptyStateView {
    @objc private func actionButtonTapped() {
        onActionTapped?()
    }
}
