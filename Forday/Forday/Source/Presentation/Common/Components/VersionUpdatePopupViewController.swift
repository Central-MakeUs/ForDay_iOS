//
//  VersionUpdatePopupViewController.swift
//  Forday
//
//  Created by Subeen on 2/25/26.
//

import UIKit
import SnapKit
import Then

/// 앱 버전 업데이트 팝업
/// - FORCE: 강제 업데이트 (단일 버튼)
/// - RECOMMEND: 권장 업데이트 (두 버튼)
/// - BLOCK: 서비스 점검 (단일 버튼)
class VersionUpdatePopupViewController: UIViewController {

    // MARK: - Types

    enum UpdateType {
        case force(storeUrl: String, message: String?)
        case recommend(storeUrl: String, message: String?)
        case block(message: String?)
    }

    // MARK: - Properties

    var onUpdateTapped: (() -> Void)?
    var onLaterTapped: (() -> Void)?
    var onConfirmTapped: (() -> Void)?

    private let updateType: UpdateType

    // MARK: - UI Components

    private let dimView = UIView()
    private let dialogView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let secondaryButton = UIButton(type: .system)
    private let primaryButton = UIButton(type: .system)

    // MARK: - Initialization

    init(updateType: UpdateType) {
        self.updateType = updateType
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

extension VersionUpdatePopupViewController {
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
            $0.setTextWithTypography(titleText, style: .header18)
            $0.textColor = .neutral900
        }

        messageLabel.do {
            $0.setTextWithTypography(messageText, style: .label14)
            $0.textColor = .neutral800
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.isHidden = messageText.isEmpty
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
            $0.isHidden = !showSecondaryButton
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

        if showSecondaryButton {
            buttonStackView.addArrangedSubview(secondaryButton)
        }
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

        if messageText.isEmpty {
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
        // 업데이트 팝업은 dim 탭으로 닫히지 않음
        secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Computed Properties

private extension VersionUpdatePopupViewController {
    var titleText: String {
        switch updateType {
        case .force:
            return "업데이트가 필요해요"
        case .recommend:
            return "새로운 버전이 있어요"
        case .block:
            return "서비스 점검 중이에요"
        }
    }

    var messageText: String {
        switch updateType {
        case .force(_, let message):
            return message ?? "더 나은 서비스를 위해 최신 버전으로 업데이트해주세요."
        case .recommend(_, let message):
            return message ?? "새로운 기능이 추가되었어요. 업데이트를 권장해요."
        case .block(let message):
            return message ?? "잠시 후 다시 시도해주세요."
        }
    }

    var primaryButtonTitle: String {
        switch updateType {
        case .force, .recommend:
            return "업데이트하기"
        case .block:
            return "확인"
        }
    }

    var secondaryButtonTitle: String? {
        switch updateType {
        case .recommend:
            return "나중에"
        case .force, .block:
            return nil
        }
    }

    var showSecondaryButton: Bool {
        switch updateType {
        case .recommend:
            return true
        case .force, .block:
            return false
        }
    }
}

// MARK: - Actions

extension VersionUpdatePopupViewController {
    @objc private func secondaryButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onLaterTapped?()
        }
    }

    @objc private func primaryButtonTapped() {
        switch updateType {
        case .force(let storeUrl, _), .recommend(let storeUrl, _):
            openAppStore(urlString: storeUrl)
        case .block:
            dismiss(animated: true) { [weak self] in
                self?.onConfirmTapped?()
            }
        }
    }

    private func openAppStore(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

#if DEBUG
#Preview("Force Update") {
    let popup = VersionUpdatePopupViewController(
        updateType: .force(
            storeUrl: "https://apps.apple.com",
            message: "보안 업데이트가 포함되어 업데이트가 필요합니다."
        )
    )
    return popup
}

#Preview("Recommend Update") {
    let popup = VersionUpdatePopupViewController(
        updateType: .recommend(
            storeUrl: "https://apps.apple.com",
            message: "새 기능이 추가되었습니다. 업데이트를 권장합니다."
        )
    )
    return popup
}

#Preview("Service Block") {
    let popup = VersionUpdatePopupViewController(
        updateType: .block(message: "현재 서비스 정기 점검 중입니다. (예정 시간: 14:00 ~ 17:00)")
    )
    return popup
}
#endif
