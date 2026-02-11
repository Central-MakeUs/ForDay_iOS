//
//  HobbySettingsCell.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import UIKit
import SnapKit
import Then

class HobbySettingsCell: UITableViewCell {

    static let identifier = "HobbySettingsCell"

    // MARK: - UI Components

    // White card container
    private let cardContainerView = UIView()
    private let hobbyIconView = UIImageView()
    private let infoLabel = UILabel()
    private let hobbyNameLabel = UILabel()
    private let archiveButton = UIButton()

    // Action buttons (outside card)
    private let actionStackView = UIStackView()
    private let timeButton = UIButton()
    private let executionButton = UIButton()
    private let goalDaysButton = UIButton()

    // MARK: - Callbacks

    var onArchiveTapped: ((Int) -> Void)?
    var onUnarchiveTapped: ((Int) -> Void)?
    var onTimeEditTapped: ((Int) -> Void)?
    var onExecutionEditTapped: ((Int) -> Void)?
    var onGoalDaysEditTapped: ((Int) -> Void)?

    // MARK: - Properties

    private var hobbyId: Int?
    private var isArchived: Bool = false

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStyle()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension HobbySettingsCell {
    private func setupStyle() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        // White card container
        cardContainerView.do {
            $0.backgroundColor = .bg001
            $0.layer.cornerRadius = 8
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.06
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 12
        }

        // Hobby icon
        hobbyIconView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .systemOrange
        }

        // Info label (30분 · 주 2회 · 66일) - label/10, neutral/600
        infoLabel.do {
            $0.textColor = .neutral600
        }

        // Hobby name - body/16, neutral/800
        hobbyNameLabel.do {
            $0.textColor = .neutral800
        }

        // Archive button (vertical: icon + text)
        archiveButton.do {
            var config = UIButton.Configuration.plain()
            config.image = .Icon.storageIn
            config.imagePlacement = .top
            config.imagePadding = 2
            config.baseForegroundColor = .neutral800
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            // Apply label/12 font
            var attributedTitle = AttributedString("보관")
            attributedTitle.font = TypographyStyle.label12.font
            config.attributedTitle = attributedTitle

            $0.configuration = config
            $0.addTarget(self, action: #selector(archiveButtonTapped), for: .touchUpInside)
        }

        // Action stack view
        actionStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.distribution = .fillEqually
        }

        // Action buttons
        configureActionButton(timeButton, title: "취미 시간 변경", action: #selector(timeButtonTapped))
        configureActionButton(executionButton, title: "실행 횟수 변경", action: #selector(executionButtonTapped))
        configureActionButton(goalDaysButton, title: "여정일 변경", action: #selector(goalDaysButtonTapped))

        actionStackView.addArrangedSubview(timeButton)
        actionStackView.addArrangedSubview(executionButton)
        actionStackView.addArrangedSubview(goalDaysButton)
    }

    private func setupLayout() {
        contentView.addSubview(cardContainerView)
        contentView.addSubview(actionStackView)

        cardContainerView.addSubview(hobbyIconView)
        cardContainerView.addSubview(infoLabel)
        cardContainerView.addSubview(hobbyNameLabel)
        cardContainerView.addSubview(archiveButton)

        // Card container
        cardContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(60)
        }

        // Hobby icon
        hobbyIconView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        // Info label (top)
        infoLabel.snp.makeConstraints {
            $0.leading.equalTo(hobbyIconView.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(12)
        }

        // Hobby name (bottom)
        hobbyNameLabel.snp.makeConstraints {
            $0.leading.equalTo(infoLabel)
            $0.top.equalTo(infoLabel.snp.bottom).offset(3)
        }

        // Archive button
        archiveButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        // Action stack view (below card)
        actionStackView.snp.makeConstraints {
            $0.top.equalTo(cardContainerView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-8)
            $0.height.equalTo(40)
        }
    }

    private func configureActionButton(_ button: UIButton, title: String, action: Selector) {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .neutral600
        config.background.backgroundColor = .bg003
        config.background.cornerRadius = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10)

        // Apply label/12 font
        var attributedTitle = AttributedString(title)
        attributedTitle.font = TypographyStyle.label12.font
        config.attributedTitle = attributedTitle

        button.configuration = config
        button.addTarget(self, action: action, for: .touchUpInside)
    }
}

// MARK: - Actions

extension HobbySettingsCell {
    @objc private func archiveButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        if isArchived {
            onUnarchiveTapped?(hobbyId)
        } else {
            onArchiveTapped?(hobbyId)
        }
    }

    @objc private func timeButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        onTimeEditTapped?(hobbyId)
    }

    @objc private func executionButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        onExecutionEditTapped?(hobbyId)
    }

    @objc private func goalDaysButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        onGoalDaysEditTapped?(hobbyId)
    }
}

// MARK: - Configuration

extension HobbySettingsCell {
    func configure(with hobby: HobbySetting, isArchived: Bool) {
        self.hobbyId = hobby.hobbyId
        self.isArchived = isArchived

        // Icon - imageCode에 따라 적절한 아이콘 표시
        hobbyIconView.image = hobby.imageAsset.icon

        // Info text (label/10)
        infoLabel.setTextWithTypography(hobby.infoDisplayText, style: .label10)

        // Hobby name (body/16)
        hobbyNameLabel.setTextWithTypography(hobby.hobbyName, style: .body16)

        // Archive button
        updateArchiveButton(isArchived: isArchived)

        // Show/hide action buttons based on archived state
        updateLayoutForArchivedState(isArchived)
    }

    private func updateArchiveButton(isArchived: Bool) {
        var config = archiveButton.configuration

        if isArchived {
            config?.image = .Icon.storageOut
            var attributedTitle = AttributedString("꺼내기")
            attributedTitle.font = TypographyStyle.label12.font
            config?.attributedTitle = attributedTitle
        } else {
            config?.image = .Icon.storageIn
            var attributedTitle = AttributedString("보관")
            attributedTitle.font = TypographyStyle.label12.font
            config?.attributedTitle = attributedTitle
        }

        archiveButton.configuration = config
    }

    private func updateLayoutForArchivedState(_ isArchived: Bool) {
        actionStackView.isHidden = isArchived

        // Update constraints
        actionStackView.snp.remakeConstraints {
            $0.top.equalTo(cardContainerView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)

            if isArchived {
                $0.height.equalTo(0)
                $0.bottom.equalToSuperview()
            } else {
                $0.height.equalTo(40)
                $0.bottom.equalToSuperview().offset(-8)
            }
        }
    }
}
