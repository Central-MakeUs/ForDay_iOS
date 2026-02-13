//
//  ReactionUserCell.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ReactionUserCell: UIView {

    // MARK: - UI Components

    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let newReactionDot = UIView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with user: ReactionUser) {
        nicknameLabel.setTextWithTypography(user.nickname, style: .label10)
        newReactionDot.isHidden = !user.newReactionUser
        profileImageView.setImage(with: user.profileImageUrl)
    }
}

// MARK: - Setup

extension ReactionUserCell {
    private func style() {
        profileImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 14  // 28pt / 2
            $0.backgroundColor = .bg003
        }

        nicknameLabel.do {
            $0.textColor = .neutral600
            $0.textAlignment = .center
        }

        newReactionDot.do {
            $0.backgroundColor = .action001
            $0.layer.cornerRadius = 3  // 6pt / 2
            $0.isHidden = true
        }
    }

    private func layout() {
        addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(newReactionDot)

        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(28)
        }

        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }

        newReactionDot.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.top).offset(-2)
            $0.trailing.equalTo(profileImageView.snp.trailing).offset(2)
            $0.width.height.equalTo(6)
        }
    }
}
