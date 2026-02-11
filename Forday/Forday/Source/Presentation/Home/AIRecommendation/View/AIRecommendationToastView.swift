//
//  AIRecommendationToastView.swift
//  Forday
//
//  Created by Subeen on 2/2/26.
//


import UIKit
import SnapKit
import Then

final class AIRecommendationToastView: UIView {

    // MARK: - UI Components

    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let messageLabel = UILabel()

    // MARK: - Properties

    private var isExpanded = false
    private var containerWidthConstraint: Constraint?

    // MARK: - Callbacks

    var onTap: (() -> Void)?

    // MARK: - Constants

    private let collapsedSize: CGFloat = 40
    private let expandedHeight: CGFloat = 40
    private let iconSize: CGFloat = 24

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

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBorder()
    }
}

// MARK: - Setup

extension AIRecommendationToastView {
    private func style() {
        backgroundColor = .clear

        containerView.do {
            $0.backgroundColor = .bg001
            $0.layer.cornerRadius = collapsedSize / 2
            $0.clipsToBounds = true
        }

        iconImageView.do {
            $0.image = .Ai.default
            $0.contentMode = .scaleAspectFit
        }

        messageLabel.do {
            $0.textColor = .neutral800
            $0.numberOfLines = 1
            $0.textAlignment = .center
            $0.alpha = 0
        }
    }

    private func layout() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(messageLabel)

        // Container - 초기 상태: 접힘 (아이콘만)
        containerView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(collapsedSize)
            containerWidthConstraint = $0.width.equalTo(collapsedSize).constraint
        }

        // Icon
        iconImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(iconSize)
        }

        // Message
        messageLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        // Self height
        snp.makeConstraints {
            $0.height.equalTo(collapsedSize)
        }
    }

    private func updateBorder() {
        containerView.applyGradientBorder(DesignGradient.gradient002, lineWidth: 1, cornerRadius: containerView.layer.cornerRadius)
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

extension AIRecommendationToastView {
    func configure(with message: String) {
        messageLabel.setTextWithTypography(message, style: .body14)
    }

    func expand(animated: Bool = true) {
        guard !isExpanded else { return }
        isExpanded = true

        let duration = animated ? 0.4 : 0

        // 컨테이너 너비를 전체로 확장
        containerWidthConstraint?.deactivate()
        containerView.snp.makeConstraints {
            containerWidthConstraint = $0.leading.equalToSuperview().constraint
        }

        // cornerRadius 변경
        containerView.layer.cornerRadius = expandedHeight / 2

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.layoutIfNeeded()
            self.messageLabel.alpha = 1
            self.updateBorder()
        }
    }

    func collapse(animated: Bool = true) {
        guard isExpanded else { return }
        isExpanded = false

        let duration = animated ? 0.3 : 0

        // 컨테이너 너비를 접힘 상태로
        containerWidthConstraint?.deactivate()
        containerView.snp.makeConstraints {
            containerWidthConstraint = $0.width.equalTo(collapsedSize).constraint
        }

        // cornerRadius 변경
        containerView.layer.cornerRadius = collapsedSize / 2

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn) {
            self.layoutIfNeeded()
            self.messageLabel.alpha = 0
            self.updateBorder()
        }
    }

    var isExpandedState: Bool {
        return isExpanded
    }

    func setInteractionEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        containerView.isUserInteractionEnabled = enabled
    }
}

#Preview {
    let view = AIRecommendationToastView()
    view.configure(with: "반가워요, 몽실님!")
    view.expand(animated: true)
    return view
}
