//
//  ReactionUserListCell.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ReactionUserListCell: UITableViewCell {

    // MARK: - UI Components

    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let reactionIconContainer = UIView()
    private let reactionIconImageView = UIImageView()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStyle()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with item: ReactionUserItem) {
        nicknameLabel.setTextWithTypography(item.nickname, style: .body14)
        profileImageView.setImage(with: item.profileImageUrl)
        reactionIconImageView.image = item.reactionType.icon
    }
}

// MARK: - Setup

extension ReactionUserListCell {
    private func setupStyle() {
        selectionStyle = .none
        backgroundColor = .clear

        profileImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 18  // 36pt / 2
            $0.backgroundColor = .bg003
        }

        nicknameLabel.do {
            $0.textColor = .neutral800
        }

        reactionIconContainer.do {
            $0.backgroundColor = .primary002  // #FFE6D1
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.action001.cgColor  // #FF9447
            $0.layer.cornerRadius = 12  // 24pt / 2
            $0.clipsToBounds = true
        }

        reactionIconImageView.do {
            $0.contentMode = .scaleAspectFit
        }
    }

    private func setupLayout() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(reactionIconContainer)
        reactionIconContainer.addSubview(reactionIconImageView)

        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(36)
        }

        nicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(reactionIconContainer.snp.leading).offset(-16)
        }

        reactionIconContainer.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        reactionIconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(16)
        }
    }
}

#if DEBUG
#Preview("ReactionUserListCell") {
    let cell = ReactionUserListCell()
    cell.configure(with: .preview)
    cell.frame = CGRect(x: 0, y: 0, width: 320, height: 44)
    return cell
}
#endif
