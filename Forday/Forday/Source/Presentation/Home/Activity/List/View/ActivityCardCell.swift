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
    private let aiIconImageView = UIImageView()
    private let activityLabel = UILabel()
    private let stickerStackView = UIStackView()
    private let stickerImageView = UIImageView()
    private let stickerCountLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)

    // MARK: - Constraints

    private var labelLeadingToAiIcon: Constraint?
    private var labelLeadingToCard: Constraint?

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

        // Reset label constraint to default (no AI icon)
        labelLeadingToAiIcon?.deactivate()
        labelLeadingToCard?.activate()
    }

    // MARK: - Configuration

    func configure(with activity: Activity) {
        // 말줄임 처리를 위해 attributedText에 lineBreakMode 추가
        let style = TypographyStyle.body14
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = style.lineHeight
        paragraphStyle.maximumLineHeight = style.lineHeight
        paragraphStyle.lineBreakMode = .byTruncatingTail

        let baselineOffset = (style.lineHeight - style.font.lineHeight) / 4

        let attributedString = NSMutableAttributedString(string: activity.content)
        attributedString.addAttributes([
            .font: style.font,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: baselineOffset,
            .kern: style.letterSpacing
        ], range: NSRange(location: 0, length: activity.content.utf16.count))

        activityLabel.attributedText = attributedString

        stickerCountLabel.setTextWithTypography("\(activity.collectedStickerNum)", style: .label12)

        // Show/hide AI badge and update layout
        let showAiIcon = activity.aiRecommended
        aiIconImageView.isHidden = !showAiIcon

        if showAiIcon {
            labelLeadingToCard?.deactivate()
            labelLeadingToAiIcon?.activate()
        } else {
            labelLeadingToAiIcon?.deactivate()
            labelLeadingToCard?.activate()
        }

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

        aiIconImageView.do {
            $0.image = .Ai.small
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }

        activityLabel.do {
            $0.textColor = .neutral900
            $0.numberOfLines = 1
            $0.lineBreakMode = .byTruncatingTail
        }

        stickerStackView.do {
            $0.axis = .horizontal
            $0.spacing = 2
            $0.alignment = .center
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

        cardView.addSubview(aiIconImageView)
        cardView.addSubview(activityLabel)
        cardView.addSubview(stickerStackView)
        cardView.addSubview(buttonStackView)

        stickerStackView.addArrangedSubview(stickerImageView)
        stickerStackView.addArrangedSubview(stickerCountLabel)

        buttonStackView.addArrangedSubview(editButton)
        buttonStackView.addArrangedSubview(deleteButton)

        cardView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
        }

        // AI 아이콘 (왼쪽 끝)
        aiIconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(14)
        }

        // 버튼 스택 (오른쪽 끝)
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

        // 스티커 스택 (버튼 왼쪽)
        stickerStackView.snp.makeConstraints {
            $0.trailing.equalTo(buttonStackView.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }

        stickerImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }

        // 활동 라벨 (AI 아이콘과 스티커 사이, 남은 공간 차지)
        activityLabel.snp.makeConstraints {
            labelLeadingToAiIcon = $0.leading.equalTo(aiIconImageView.snp.trailing).offset(4).constraint
            labelLeadingToCard = $0.leading.equalToSuperview().offset(16).constraint
            $0.trailing.equalTo(stickerStackView.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }

        // activityLabel이 줄어들 수 있도록 compression resistance 낮춤
        activityLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        activityLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        // 기본: AI 아이콘 숨김 상태
        labelLeadingToAiIcon?.deactivate()
        labelLeadingToCard?.activate()
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
