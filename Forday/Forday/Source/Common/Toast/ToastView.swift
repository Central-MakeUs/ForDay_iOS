//
//  ToastView.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import SnapKit
import Then

enum ToastPosition {
    case top
    case bottom
    /// 버튼 위에 표시 (하단에서 지정된 간격만큼 위)
    case aboveButton(bottomInset: CGFloat)
}

enum ToastIcon {
    case success    // checkCircle
    case error      // xmarkCircle
    case none       // 아이콘 없음
}

final class ToastView: UIView {

    // MARK: - UI Components

    private let iconImageView = UIImageView()
    private let messageLabel = UILabel()
    private let actionButton = UIButton()

    // MARK: - Properties

    private var onAction: (() -> Void)?
    private var actionTitle: String?
    private var icon: ToastIcon = .success
    private var position: ToastPosition = .top

    // MARK: - Initialization

    init(
        message: String,
        icon: ToastIcon = .success,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.onAction = onAction
        self.actionTitle = actionTitle
        self.icon = icon
        super.init(frame: .zero)
        messageLabel.text = message

        if actionTitle != nil {
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }

        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // bounds 체크를 수동으로 수행
        if bounds.contains(point) {
            // 버튼 체크
            let buttonPoint = actionButton.convert(point, from: self)
            if actionButton.bounds.contains(buttonPoint) && !actionButton.isHidden {
                return actionButton
            }
            return self
        }
        return nil
    }

    // MARK: - Public Methods

    /// 화면 상단에 토스트 메시지 표시 (액션 버튼 없음)
    static func show(message: String, duration: TimeInterval = 2.0) {
        show(message: message, icon: .success, position: .top, actionTitle: nil, duration: duration, onAction: nil)
    }

    /// 화면에 토스트 메시지 표시 (전체 옵션)
    static func show(
        message: String,
        icon: ToastIcon = .success,
        position: ToastPosition = .top,
        actionTitle: String? = nil,
        duration: TimeInterval = 3.0,
        onAction: (() -> Void)? = nil
    ) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        let toast = ToastView(message: message, icon: icon, actionTitle: actionTitle, onAction: onAction)
        toast.position = position
        window.addSubview(toast)

        toast.snp.makeConstraints {
            switch position {
            case .top:
                // safe area top + navigation bar height(44) + 10pt spacing
                $0.top.equalTo(window.safeAreaLayoutGuide.snp.top).offset(54)
            case .bottom:
                // safe area bottom + tab bar height(49) + floating button(56) + spacing(16) + extra(16)
                $0.bottom.equalTo(window.safeAreaLayoutGuide.snp.bottom).offset(-137)
            case .aboveButton(let bottomInset):
                // 지정된 간격만큼 하단에서 띄움
                $0.bottom.equalTo(window.safeAreaLayoutGuide.snp.bottom).offset(-bottomInset)
            }
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.greaterThanOrEqualTo(48)
        }

        window.bringSubviewToFront(toast)
        toast.alpha = 0

        // 페이드 인
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            toast.alpha = 1
        } completion: { _ in
            // 일정 시간 후 페이드 아웃
            UIView.animate(withDuration: 0.3, delay: duration, options: [.curveEaseIn, .allowUserInteraction]) {
                toast.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
    
    /// 성공 토스트 표시 (아이콘 없음, 하단 표시)
    static func showSuccess(message: String, duration: TimeInterval = 3.0) {
        show(message: message, icon: .none, position: .bottom, duration: duration)
    }

    /// 에러 토스트 표시 (아이콘 없음, 하단 표시)
    static func showError(message: String, duration: TimeInterval = 3.0) {
        show(message: message, icon: .none, position: .bottom, duration: duration)
    }
}

// MARK: - Setup

extension ToastView {
    private func style() {
        backgroundColor = UIColor.black.withAlphaComponent(0.68)
        layer.cornerRadius = 12
        clipsToBounds = true
        isUserInteractionEnabled = true

        iconImageView.do {
            switch icon {
            case .success:
                $0.image = .Icon.checkCircle
                $0.isHidden = false
            case .error:
                $0.image = .Icon.xmarkCircle
                $0.isHidden = false
            case .none:
                $0.isHidden = true
            }
            $0.contentMode = .scaleAspectFit
        }

        messageLabel.do {
            $0.textColor = .white
            $0.numberOfLines = 0
            $0.applyTypography(.header14)
        }

        actionButton.do {
            var config = UIButton.Configuration.plain()
            config.baseForegroundColor = .neutral100
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)

            if let title = actionTitle {
                var attributedTitle = AttributedString(title)
                attributedTitle.font = TypographyStyle.label12.font
                config.attributedTitle = attributedTitle
            }

            $0.configuration = config
            $0.isUserInteractionEnabled = true
            $0.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        }
    }

    private func layout() {
        addSubview(iconImageView)
        addSubview(messageLabel)
        addSubview(actionButton)

        let hasIcon = icon != .none

        if hasIcon {
            iconImageView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(20)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(20)
            }
        }

        if actionButton.isHidden {
            messageLabel.snp.makeConstraints {
                if hasIcon {
                    $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
                } else {
                    $0.leading.equalToSuperview().offset(20)
                }
                $0.trailing.equalToSuperview().offset(-20)
                $0.top.equalToSuperview().offset(12)
                $0.bottom.equalToSuperview().offset(-12)
            }
        } else {
            messageLabel.snp.makeConstraints {
                if hasIcon {
                    $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
                } else {
                    $0.leading.equalToSuperview().offset(20)
                }
                $0.top.equalToSuperview().offset(12)
                $0.bottom.equalToSuperview().offset(-12)
            }

            actionButton.snp.makeConstraints {
                $0.leading.equalTo(messageLabel.snp.trailing).offset(8)
                $0.trailing.equalToSuperview().offset(-20)
                $0.centerY.equalToSuperview()
            }

            // Set content hugging priority so message label expands and action button stays compact
            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
    }

    @objc private func actionButtonTapped() {
        onAction?()

        // Dismiss toast immediately when action is tapped
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.transform = CGAffineTransform(translationX: 0, y: -100)
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
