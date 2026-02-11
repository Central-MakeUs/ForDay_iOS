//
//  ProfileHeaderView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ProfileHeaderView: UIView {

    // MARK: - UI Components

    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let stickerCountLabel = UILabel()

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

    func configure(with info: UserInfo) {
        nicknameLabel.setTextWithTypography(info.nickname, style: .header18)
        stickerCountLabel.setTextWithTypography("\(info.totalCollectedStickerCount)개 스티커 수집 중", style: .label14)

        // Profile image (캐시 무시하고 항상 서버에서 새로 받아옴)
        if let imageUrlString = info.profileImageUrl,
           let imageUrl = URL(string: imageUrlString) {
            profileImageView.kf.setImage(
                with: imageUrl,
                placeholder: UIImage.Icon.defaultProfile,
                options: [
                    .transition(.fade(0.2)),
                    .forceRefresh
                ]
            )
        } else {
            profileImageView.image = .Icon.defaultProfile
        }
    }
}

// MARK: - Setup

extension ProfileHeaderView {
    private func style() {
        backgroundColor = .systemBackground

        profileImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 30
            $0.image = .Icon.defaultProfile
        }

        nicknameLabel.do {
            $0.textColor = .neutral900
        }

        stickerCountLabel.do {
            $0.textColor = .neutral600
        }
    }

    private func layout() {
        addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(stickerCountLabel)

        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(60)
        }

        nicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(profileImageView.snp.centerY).offset(-2)
        }

        stickerCountLabel.snp.makeConstraints {
            $0.leading.equalTo(nicknameLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(profileImageView.snp.centerY).offset(2)
        }
    }
}
