//
//  AIRecommendationInputToastView.swift
//  Forday
//
//  Created by Subeen on 2/2/26.
//


import UIKit
import SnapKit
import Then

final class AIRecommendationInputToastView: UIView {

    // MARK: - UI Components

    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let messageLabel = UILabel()
    private let chevronImageView = UIImageView()

    // MARK: - Callbacks

    var onTap: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension AIRecommendationInputToastView {
    private func style() {
        backgroundColor = .clear

        containerView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 20
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor(red: 244/255, green: 162/255, blue: 97/255, alpha: 1).cgColor
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 5
            $0.layer.shadowOpacity = 0.12
            $0.clipsToBounds = false
        }

        iconImageView.do {
            $0.image = .Ai.default
            $0.contentMode = .scaleAspectFit
        }

        messageLabel.do {
            $0.textColor = .neutral800
            $0.numberOfLines = 1
        }

        chevronImageView.do {
            $0.image = .Icon.chevronRight
            $0.tintColor = .neutral500
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(messageLabel)
        containerView.addSubview(chevronImageView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(22)
        }

        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }

        messageLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }

        snp.makeConstraints {
            $0.height.equalTo(40)
        }
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        onTap?()
    }
}

// MARK: - Public Methods

extension AIRecommendationInputToastView {
    func configure(with message: String) {
        messageLabel.setTextWithTypography(message, style: .body14)
    }

    func setInteractionEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        containerView.isUserInteractionEnabled = enabled
    }
}

#Preview {
    let view = AIRecommendationInputToastView()
    view.configure(with: "포데이 AI 추천 활동 보기")
    return view
}
