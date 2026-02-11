//
//  DeleteAccountView.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit
import SnapKit
import Then

final class DeleteAccountView: UIView {

    // MARK: - UI Components

    // Custom Navigation Bar
    private let navigationBarView = UIView()
    let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    // Content
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()

    // Header
    private let sorryImageView = UIImageView()
    private let headerTitleLabel = UILabel()
    private let headerDescriptionLabel = UILabel()

    // Info Cards
    private let memberInfoCard = DeleteAccountInfoCardView(
        title: "회원정보",
        description: "소셜 계정 로그인아이디 정보가 삭제됩니다."
    )
    private let activityInfoCard = DeleteAccountInfoCardView(
        title: "활동기록 정보",
        description: "수집된 취미명, 목적, 취미빈도, 취미시간, AI 추천활동, 활동 등\n모든 취미정보와 활동기록과 관련된 정보들이 삭제됩니다."
    )

    // Checkbox
    private let checkboxContainerView = UIView()
    let checkboxButton = UIButton(type: .custom)
    private let checkboxLabel = UILabel()

    // Bottom Button
    let deleteButton = UIButton(type: .system)

    // MARK: - Properties

    var isChecked: Bool = false {
        didSet {
            updateCheckboxState()
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension DeleteAccountView {
    private func style() {
        backgroundColor = .bg001

        // Navigation Bar
        navigationBarView.do {
            $0.backgroundColor = .bg001
        }

        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral900
        }

        titleLabel.do {
            $0.setTextWithTypography("탈퇴하기", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        // Scroll View
        scrollView.do {
            $0.backgroundColor = .bg001
            $0.showsVerticalScrollIndicator = false
        }

        scrollContentView.do {
            $0.backgroundColor = .bg001
        }

        // Header
        sorryImageView.do {
            $0.image = .Icon.sorry
            $0.contentMode = .scaleAspectFit
        }

        headerTitleLabel.do {
            $0.setTextWithTypography("더 좋은 서비스를 제공하지 못하여 죄송합니다.", style: .header18)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        headerDescriptionLabel.do {
            $0.setTextWithTypography("탈퇴하시면 모든 활동기록과 데이터가 파기되며\n모든 데이터는 복구가 불가능합니다.", style: .label14)
            $0.textColor = .neutral600
            $0.numberOfLines = 0
        }

        // Checkbox
        checkboxContainerView.do {
            $0.backgroundColor = .clear
            $0.isUserInteractionEnabled = true
        }

        checkboxButton.do {
            $0.setImage(.Onoff.checkboxSquareFalse, for: .normal)
            $0.setImage(.Onoff.checkboxSquareTrue, for: .selected)
        }

        checkboxLabel.do {
            $0.setTextWithTypography("모든 정보 및 활동기록 데이터 삭제에 동의합니다.", style: .label14)
            $0.textColor = .neutral900
        }

        // Delete Button
        deleteButton.do {
            $0.setTitle("탈퇴하기", for: .normal)
            $0.titleLabel?.applyTypography(.header16)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
            $0.backgroundColor = .action001
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.isEnabled = false
        }
    }

    private func layout() {
        addSubview(navigationBarView)
        navigationBarView.addSubview(backButton)
        navigationBarView.addSubview(titleLabel)

        addSubview(scrollView)
        scrollView.addSubview(scrollContentView)

        scrollContentView.addSubview(sorryImageView)
        scrollContentView.addSubview(headerTitleLabel)
        scrollContentView.addSubview(headerDescriptionLabel)
        scrollContentView.addSubview(memberInfoCard)
        scrollContentView.addSubview(activityInfoCard)
        scrollContentView.addSubview(checkboxContainerView)
        checkboxContainerView.addSubview(checkboxButton)
        checkboxContainerView.addSubview(checkboxLabel)

        addSubview(deleteButton)

        // Navigation Bar Layout
        navigationBarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        // Scroll View Layout
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(deleteButton.snp.top).offset(-16)
        }

        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // Header
        sorryImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(48)
        }

        headerTitleLabel.snp.makeConstraints {
            $0.top.equalTo(sorryImageView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        headerDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(headerTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // Info Cards
        memberInfoCard.snp.makeConstraints {
            $0.top.equalTo(headerDescriptionLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        activityInfoCard.snp.makeConstraints {
            $0.top.equalTo(memberInfoCard.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // Checkbox
        checkboxContainerView.snp.makeConstraints {
            $0.top.equalTo(activityInfoCard.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(24)
            $0.bottom.equalToSuperview().offset(-20)
        }

        checkboxButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        checkboxLabel.snp.makeConstraints {
            $0.leading.equalTo(checkboxButton.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        // Delete Button
        deleteButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(56)
        }
    }

    private func updateCheckboxState() {
        checkboxButton.isSelected = isChecked
        deleteButton.isEnabled = isChecked
        deleteButton.alpha = isChecked ? 1.0 : 0.5
    }
}

// MARK: - DeleteAccountInfoCardView

final class DeleteAccountInfoCardView: UIView {

    // MARK: - UI Components

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    // MARK: - Initialization

    init(title: String, description: String) {
        super.init(frame: .zero)
        style(title: title, description: description)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension DeleteAccountInfoCardView {
    private func style(title: String, description: String) {
        backgroundColor = .bg002
        layer.cornerRadius = 12
        clipsToBounds = true

        titleLabel.do {
            $0.setTextWithTypography(title, style: .header14)
            $0.textColor = .neutral900
        }

        descriptionLabel.do {
            $0.setTextWithTypography(description, style: .label12)
            $0.textColor = .neutral600
            $0.numberOfLines = 0
        }
    }

    private func layout() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}

#if DEBUG
#Preview {
    DeleteAccountView()
}
#endif
