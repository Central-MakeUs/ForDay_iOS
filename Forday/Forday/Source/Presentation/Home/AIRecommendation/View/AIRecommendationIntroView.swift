//
//  AIRecommendationIntroView.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import SnapKit
import Then

/// AI 추천 상태에 따른 인트로 뷰 구성
enum AIRecommendationState {
    /// 처음 사용 (count == 3): AI 추천받기 버튼만
    case initial
    /// 사용 가능 (count == 1 or 2): AI 추천받기 + 추천 받은 활동리스트 버튼
    case available
    /// 소진됨 (count == 0): 비활성화된 안내 + 추천 받은 활동리스트 버튼
    case exhausted

    static func from(aiCallRemainingCount: Int) -> AIRecommendationState {
        switch aiCallRemainingCount {
        case 3:
            return .initial
        case 1, 2:
            return .available
        default:
            return .exhausted
        }
    }
}

class AIRecommendationIntroView: UIView {

    // MARK: - Properties

    private let aiImageView = UIImageView()
    private let recommendButton = UIButton()
    private let activityListButton = UIButton()

    private var state: AIRecommendationState = .initial

    // MARK: - Callbacks

    var onAIRecommendTapped: (() -> Void)?
    var onActivityListTapped: (() -> Void)?

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
}

// MARK: - Setup

extension AIRecommendationIntroView {
    private func style() {
        backgroundColor = .neutralWhite

        aiImageView.do {
            $0.image = .Ai.default
            $0.contentMode = .scaleAspectFit
        }

        // AI 추천받기 버튼 (기본 스타일)
        recommendButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .primary003
            config.baseForegroundColor = .action001
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 60, bottom: 12, trailing: 60)

            $0.configuration = config
            $0.setTitleWithTypography("AI 추천받기", style: .header14)
        }

        // 추천 받은 활동리스트 버튼
        activityListButton.do {
            var config = UIButton.Configuration.plain()
            config.baseForegroundColor = .neutral700

            $0.configuration = config
            $0.setTitleWithTypography("추천 받은 활동리스트", style: .body14)
            $0.isHidden = true
        }
    }

    private func layout() {
        addSubview(aiImageView)
        addSubview(recommendButton)
        addSubview(activityListButton)

        aiImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
        }

        recommendButton.snp.makeConstraints {
            $0.top.equalTo(aiImageView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().offset(-60)
        }

        activityListButton.snp.makeConstraints {
            $0.top.equalTo(recommendButton.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
    }

    private func setupActions() {
        recommendButton.addTarget(
            self,
            action: #selector(recommendButtonTapped),
            for: .touchUpInside
        )
        activityListButton.addTarget(
            self,
            action: #selector(activityListButtonTapped),
            for: .touchUpInside
        )
    }

    @objc private func recommendButtonTapped() {
        onAIRecommendTapped?()
    }

    @objc private func activityListButtonTapped() {
        onActivityListTapped?()
    }
}

// MARK: - Public Methods

extension AIRecommendationIntroView {
    /// 상태에 따라 뷰 구성
    func configure(aiCallRemainingCount: Int) {
        let state = AIRecommendationState.from(aiCallRemainingCount: aiCallRemainingCount)
        self.state = state

        switch state {
        case .initial:
            // AI 추천받기 버튼만 활성화
            configureRecommendButton(enabled: true)
            activityListButton.isHidden = true

        case .available:
            // AI 추천받기 + 활동리스트 버튼 모두 표시
            configureRecommendButton(enabled: true)
            activityListButton.isHidden = false

        case .exhausted:
            // 비활성화 상태 + 활동리스트 버튼
            configureRecommendButton(enabled: false)
            activityListButton.isHidden = false
        }
    }

    private func configureRecommendButton(enabled: Bool) {
        if enabled {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .primary003
            config.baseForegroundColor = .action001
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 60, bottom: 12, trailing: 60)

            recommendButton.configuration = config
            recommendButton.setTitleWithTypography("AI 추천받기", style: .header14)
            recommendButton.isEnabled = true
        } else {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .neutral200
            config.baseForegroundColor = .neutral500
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)

            recommendButton.configuration = config
            recommendButton.setTitleWithTypography("오늘의 AI 추천 횟수를 다 썼어요.", style: .header14)
            recommendButton.isEnabled = false
        }
    }
}

#Preview {
    let view = AIRecommendationIntroView()
    view.configure(aiCallRemainingCount: 2)
    return view
}
