//
//  CommonPopupViewController.swift
//  Forday
//
//  Created by Subeen on 2/6/26.
//

import UIKit
import SnapKit
import Then

class CommonPopupViewController: UIViewController {

    // MARK: - Properties

    var onPrimaryAction: (() -> Void)?
    var onSecondaryAction: (() -> Void)?

    private let popupTitle: String
    private let popupMessage: String
    private let primaryButtonTitle: String
    private let secondaryButtonTitle: String?

    // MARK: - UI Components

    private let dimView = UIView()
    private let dialogView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let secondaryButton = UIButton(type: .system)
    private let primaryButton = UIButton(type: .system)

    // MARK: - Initialization

    init(
        title: String,
        message: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String? = nil
    ) {
        self.popupTitle = title
        self.popupMessage = message
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupActions()
    }
}

// MARK: - Setup

extension CommonPopupViewController {
    private func style() {
        view.backgroundColor = .clear

        dimView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }

        dialogView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }

        titleLabel.do {
            $0.setTextWithTypography(popupTitle, style: .header18)
            $0.textColor = .neutral900
        }

        messageLabel.do {
            $0.setTextWithTypography(popupMessage, style: .label14)
            $0.textColor = .neutral800
            $0.textAlignment = .left
            $0.numberOfLines = 0
            $0.isHidden = popupMessage.isEmpty
        }

        buttonStackView.do {
            $0.axis = .horizontal
            $0.spacing = 20
            $0.distribution = .fillEqually
        }

        secondaryButton.do {
            $0.setTitle(secondaryButtonTitle, for: .normal)
            $0.titleLabel?.applyTypography(.header14)
            $0.setTitleColor(.neutral900, for: .normal)
            $0.backgroundColor = .action003
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
            $0.isHidden = secondaryButtonTitle == nil
        }

        primaryButton.do {
            $0.setTitle(primaryButtonTitle, for: .normal)
            $0.titleLabel?.applyTypography(.header14)
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = .action001
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }
    }

    private func layout() {
        view.addSubview(dimView)
        view.addSubview(dialogView)
        dialogView.addSubview(titleLabel)
        dialogView.addSubview(messageLabel)
        dialogView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(secondaryButton)
        buttonStackView.addArrangedSubview(primaryButton)

        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        dialogView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(312)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        if popupMessage.isEmpty {
            buttonStackView.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(20)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.height.equalTo(40)
                $0.bottom.equalToSuperview().offset(-24)
            }
        } else {
            messageLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(10)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
            }

            buttonStackView.snp.makeConstraints {
                $0.top.equalTo(messageLabel.snp.bottom).offset(20)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.height.equalTo(40)
                $0.bottom.equalToSuperview().offset(-24)
            }
        }
    }

    private func setupActions() {
        let dimTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        dimView.addGestureRecognizer(dimTapGesture)

        secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Actions

extension CommonPopupViewController {
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }

    @objc private func secondaryButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onSecondaryAction?()
        }
    }

    @objc private func primaryButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onPrimaryAction?()
        }
    }
}

#if DEBUG
#Preview("CommonPopupViewController") {
    let popup = CommonPopupViewController(
        title: "이 활동을 삭제하시겠어요?",
        message: "삭제 시 복구는 안돼요!",
        primaryButtonTitle: "삭제하기",
        secondaryButtonTitle: "닫기"
    )
    return popup
}
#endif
