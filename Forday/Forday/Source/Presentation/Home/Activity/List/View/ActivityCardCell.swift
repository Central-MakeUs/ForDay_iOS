//
//  ActivityCardCell.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//

import UIKit
import SnapKit
import Then

class ActivityCardCell: UITableViewCell {

    static let identifier = "ActivityCardCell"
    static let cellHeight: CGFloat = 62  // 52 (content) + 10 (bottom spacing)

    // MARK: - UI Components

    private let cardView = UIView()
    private let contentStackView = UIStackView()
    private let aiIconImageView = UIImageView()
    private let activityLabel = UILabel()
    private let stickerImageView = UIImageView()
    private let stickerCountLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)

    // MARK: - Callbacks

    var onEditTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStyle()
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onEditTapped = nil
        onDeleteTapped = nil
        aiIconImageView.isHidden = true
        deleteButton.isHidden = true
    }

    // MARK: - Configuration

    func configure(with activity: Activity) {
        activityLabel.setTextWithTypography(activity.content, style: .body14)
        stickerCountLabel.setTextWithTypography("\(activity.collectedStickerNum)", style: .label12)

        // Show/hide AI badge
        aiIconImageView.isHidden = !activity.aiRecommended

        // Show/hide delete button based on deletable flag
        deleteButton.isHidden = !activity.deletable
    }
}

// MARK: - Setup

extension ActivityCardCell {
    private func setupStyle() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.do {
            $0.backgroundColor = .bg001
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.clipsToBounds = true
        }

        contentStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }

        aiIconImageView.do {
            $0.image = .Ai.small
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }

        activityLabel.do {
            $0.textColor = .neutral900
            $0.numberOfLines = 1
        }

        stickerImageView.do {
            $0.image = .My.stickerCountMy
            $0.contentMode = .scaleAspectFit
        }

        stickerCountLabel.do {
            $0.textColor = .neutral500
            $0.textAlignment = .center
        }

        buttonStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }

        editButton.do {
            $0.setImage(.Icon.edit, for: .normal)
            $0.tintColor = .neutral400
        }

        deleteButton.do {
            $0.setImage(.Icon.trash, for: .normal)
            $0.tintColor = .neutral400
            $0.isHidden = true
        }
    }

    private func setupLayout() {
        contentView.addSubview(cardView)

        cardView.addSubview(contentStackView)
        cardView.addSubview(buttonStackView)

        contentStackView.addArrangedSubview(aiIconImageView)
        contentStackView.addArrangedSubview(activityLabel)
        contentStackView.addArrangedSubview(stickerImageView)
        contentStackView.addArrangedSubview(stickerCountLabel)

        buttonStackView.addArrangedSubview(editButton)
        buttonStackView.addArrangedSubview(deleteButton)

        cardView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
        }

        contentStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(buttonStackView.snp.leading).offset(-8)
        }

        aiIconImageView.snp.makeConstraints {
            $0.size.equalTo(14)
        }

        stickerImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }

        buttonStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        editButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        deleteButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        // Set content hugging/compression priorities
        activityLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        activityLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func setupActions() {
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    @objc private func editButtonTapped() {
        onEditTapped?()
    }

    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }
}

#if DEBUG
#Preview("ActivityCardCell - AI Recommended") {
    let cell = ActivityCardCell()
    cell.configure(with: .preview)
    cell.frame = CGRect(x: 0, y: 0, width: 360, height: ActivityCardCell.cellHeight)
    return cell
}

#Preview("ActivityCardCell - Deletable") {
    let cell = ActivityCardCell()
    cell.configure(with: .previewDeletable)
    cell.frame = CGRect(x: 0, y: 0, width: 360, height: ActivityCardCell.cellHeight)
    return cell
}

#Preview("ActivityCardCell - AI + Deletable") {
    let cell = ActivityCardCell()
    cell.configure(with: .previewAIDeletable)
    cell.frame = CGRect(x: 0, y: 0, width: 360, height: ActivityCardCell.cellHeight)
    return cell
}
#endif
