//
//  UserInfoView.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class UserInfoView: UIView {

    // MARK: - UI Components

    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()

    // MARK: - Properties

    var onTap: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(profileImageUrl: String?, nickname: String) {
        nicknameLabel.setTextWithTypography(nickname, style: .label12)

        if let urlString = profileImageUrl, let url = URL(string: urlString) {
            profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "person.circle.fill"),
                options: [.transition(.fade(0.2))]
            )
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .systemGray3
        }
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        onTap?()
    }
}

// MARK: - Setup

extension UserInfoView {
    private func style() {
        profileImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .systemGray6
        }

        nicknameLabel.do {
            $0.textColor = .neutral600
        }
    }

    private func layout() {
        addSubview(profileImageView)
        addSubview(nicknameLabel)

        profileImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        nicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(4)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        // Make profile image circular after layout
        DispatchQueue.main.async {
            self.profileImageView.layer.cornerRadius = 10
        }
    }
}
