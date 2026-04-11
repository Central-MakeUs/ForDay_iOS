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

    private let bubbleImageView = UIImageView()
    private let iconImageView = UIImageView()
    private let messageContainerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton()

    // MARK: - Properties

    var onActionTapped: (() -> Void)?

    /// 게스트 모드 레이아웃 (아이콘과 텍스트가 겹치지 않음)
    private var isGuestLayout: Bool = false

    /// 소식 탭 레이아웃 (sorryBubble + emptyBox 조합)
    private var isStoriesLayout: Bool = false

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
        resetToDefaultLayout()
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
        resetToDefaultLayout()
        iconImageView.image = .Icon.emptyBox
        iconImageView.alpha = 0.4
        titleLabel.setTextWithTypography("활동을 기록해보세요!", style: .header16)
        subtitleLabel.setTextWithTypography("당신의 활동기록이 궁금해요.", style: .label14)
        subtitleLabel.isHidden = false

        // onActionTapped가 nil이면 버튼 숨김 (IN_PROGRESS 취미가 없는 경우)
        if let onActionTapped = onActionTapped {
            var config = actionButton.configuration
            var attributedTitle = AttributedString("활동 기록하기")
            attributedTitle.font = TypographyStyle.label12.font
            config?.attributedTitle = attributedTitle
            actionButton.configuration = config
            actionButton.isHidden = false
            self.onActionTapped = onActionTapped
        } else {
            actionButton.isHidden = true
            self.onActionTapped = nil
        }
    }

    /// Configure for hobby cards empty state
    func configureForHobbyCards() {
        resetToDefaultLayout()
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
        resetToDefaultLayout()
        iconImageView.image = .Icon.emptyBox
        iconImageView.alpha = 0.4
        titleLabel.setTextWithTypography("아직 스크랩한 기록이 없어요.", style: .header16)
        subtitleLabel.setTextWithTypography("마음에 드는 취미활동을 둘러볼까요?", style: .label14)
        subtitleLabel.isHidden = false
        actionButton.isHidden = true
        self.onActionTapped = nil
    }

    /// Configure for notifications empty state
    func configureForNotifications() {
        resetToDefaultLayout()
        iconImageView.image = .Icon.emptyBox
        iconImageView.alpha = 0.4
        titleLabel.setTextWithTypography("새로운 알림이 없어요.", style: .body14)
        titleLabel.textColor = .neutral600
        subtitleLabel.isHidden = true
        actionButton.isHidden = true
        self.onActionTapped = nil
    }

    /// Configure for notification permission denied state
    func configureForNotificationPermissionDenied() {
        resetToDefaultLayout()
        iconImageView.image = .Icon.emptyBox
        iconImageView.alpha = 0.4
        titleLabel.setTextWithTypography("알림 권한이 꺼져있어요.", style: .body14)
        titleLabel.textColor = .neutral600
        subtitleLabel.setTextWithTypography("알림을 받으려면 설정에서 권한을 허용해주세요.", style: .label12)
        subtitleLabel.textColor = .neutral500
        subtitleLabel.isHidden = false
        actionButton.isHidden = true
        self.onActionTapped = nil
    }

    /// Configure for stories empty state (활동기록 없음)
    func configureForStories() {
        isStoriesLayout = true
        updateLayoutForStoriesMode()

        bubbleImageView.image = .Icon.sorryBubble
        bubbleImageView.isHidden = false
        iconImageView.image = .Icon.emptyBox
        iconImageView.alpha = 1.0
        titleLabel.setTextWithTypography("아직 활동기록이 존재하지 않아요", style: .body14)
        titleLabel.textColor = .neutral600
        subtitleLabel.isHidden = true
        actionButton.isHidden = true
        self.onActionTapped = nil
    }

    /// Configure for guest activity empty state (로그인 유도)
    func configureForGuestActivity(onActionTapped: (() -> Void)? = nil) {
        resetToDefaultLayout()
        isGuestLayout = true
        updateLayoutForGuestMode()

        iconImageView.image = .Icon.sorryBubble
        iconImageView.alpha = 1.0
        titleLabel.setTextWithTypography("활동 기록은 로그인 이후에\n확인이 가능해요.", style: .header16)
        subtitleLabel.setTextWithTypography("SNS로 시작해보세요!", style: .label14)
        subtitleLabel.isHidden = false

        var config = actionButton.configuration
        var attributedTitle = AttributedString("SNS로 시작하기")
        attributedTitle.font = TypographyStyle.label12.font
        config?.attributedTitle = attributedTitle
        actionButton.configuration = config
        actionButton.isHidden = false

        self.onActionTapped = onActionTapped
    }

    /// 게스트 모드 레이아웃 업데이트 (아이콘-텍스트 분리형)
    private func updateLayoutForGuestMode() {
        // sorryBubble 아이콘: 80x80
        iconImageView.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.width.equalTo(80)
            $0.height.equalTo(80)
        }

        // 메시지 컨테이너: 아이콘 아래에 배치 (겹치지 않음)
        messageContainerView.snp.remakeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }

    /// 소식 탭 레이아웃 업데이트 (sorryBubble + emptyBox 조합, 겹침 없음)
    private func updateLayoutForStoriesMode() {
        // bubbleImageView: 48x48, 상단 중앙
        bubbleImageView.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.height.equalTo(48)
        }

        // emptyBox: 160x140, bubbleImageView 바로 아래
        iconImageView.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bubbleImageView.snp.bottom)
            $0.width.equalTo(160)
            $0.height.equalTo(140)
        }

        // 메시지 컨테이너: emptyBox 아래 40pt
        messageContainerView.snp.remakeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }

    /// 기본 레이아웃으로 복원 (emptyBox 스타일)
    private func resetToDefaultLayout() {
        let needsReset = isGuestLayout || isStoriesLayout

        // Stories 레이아웃 복원
        if isStoriesLayout {
            bubbleImageView.isHidden = true
            titleLabel.textColor = .neutral900
        }

        isStoriesLayout = false
        isGuestLayout = false

        guard needsReset else { return }

        // emptyBox 이미지: 160x140
        iconImageView.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.width.equalTo(160)
            $0.height.equalTo(140)
        }

        // 메시지 컨테이너: 이미지와 겹치도록 배치
        messageContainerView.snp.remakeConstraints {
            $0.top.equalTo(iconImageView.snp.top).offset(77)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - Setup

extension EmptyStateView {
    private func style() {
        backgroundColor = .systemBackground

        bubbleImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }

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
        // bubbleImageView (소식 탭용, 기본 hidden)
        addSubview(bubbleImageView)
        // emptyBox 이미지가 맨 뒤에 깔림
        addSubview(iconImageView)
        // 메시지 컨테이너가 이미지 위에 위치
        addSubview(messageContainerView)
        messageContainerView.addSubview(titleLabel)
        messageContainerView.addSubview(subtitleLabel)
        messageContainerView.addSubview(actionButton)

        // bubbleImageView: 48x48, 기본적으로 숨김
        bubbleImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.height.equalTo(48)
        }

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
