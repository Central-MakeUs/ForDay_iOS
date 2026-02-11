//
//  EditProfileView.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import SnapKit
import Then

class EditProfileView: UIView {

    // MARK: - Properties

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Profile Image Section
    let profileImageView = UIImageView()
    let cameraIconView = UIImageView()

    // Nickname Input Section
    let nicknameLabel = UILabel()
    let inputContainerView = UIView()
    let nicknameTextField = UITextField()
    let duplicateCheckButton = UIButton()
    let validationLabel = UILabel()

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

extension EditProfileView {
    private func style() {
        backgroundColor = .systemBackground

        scrollView.do {
            $0.showsVerticalScrollIndicator = false
            $0.keyboardDismissMode = .interactive
        }

        // Profile Image
        profileImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .systemGray5
            $0.layer.cornerRadius = 50
            $0.isUserInteractionEnabled = true
        }

        cameraIconView.do {
            $0.image = UIImage(systemName: "camera.fill")
            $0.tintColor = .white
            $0.contentMode = .scaleAspectFit
            $0.backgroundColor = .label
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
        }

        // Nickname Label
        nicknameLabel.do {
            $0.setTextWithTypography("닉네임", style: .label12)
            $0.textColor = .secondaryLabel
        }

        // Input Container
        inputContainerView.do {
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 12
        }

        // Nickname TextField
        nicknameTextField.do {
            $0.placeholder = "닉네임을 입력해 주세요."
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .label
            $0.borderStyle = .none
            $0.clearButtonMode = .whileEditing
            $0.autocorrectionType = .no
            $0.autocapitalizationType = .none
            $0.spellCheckingType = .no
        }

        // Duplicate Check Button
        duplicateCheckButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "중복확인"
            config.baseBackgroundColor = .label
            config.baseForegroundColor = .systemBackground
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)

            $0.configuration = config
            $0.applyTypography(.label12)
        }

        // Validation Label
        validationLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .systemRed
            $0.numberOfLines = 0
            $0.isHidden = true
        }
    }

    private func layout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileImageView)
        contentView.addSubview(cameraIconView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(inputContainerView)
        contentView.addSubview(validationLabel)

        inputContainerView.addSubview(nicknameTextField)
        inputContainerView.addSubview(duplicateCheckButton)

        // ScrollView
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }

        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // Profile Image
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }

        // Camera Icon
        cameraIconView.snp.makeConstraints {
            $0.trailing.equalTo(profileImageView.snp.trailing)
            $0.bottom.equalTo(profileImageView.snp.bottom)
            $0.width.height.equalTo(32)
        }

        // Nickname Label
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // Input Container
        inputContainerView.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // Nickname TextField
        nicknameTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(duplicateCheckButton.snp.leading).offset(-16)
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.greaterThanOrEqualTo(44)
        }

        // Duplicate Check Button
        duplicateCheckButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(nicknameTextField)
            $0.height.equalTo(28)
        }

        // Validation Label
        validationLabel.snp.makeConstraints {
            $0.top.equalTo(inputContainerView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
    }
}

// MARK: - Public Methods

extension EditProfileView {
    func updateProfileImage(_ image: UIImage?) {
        profileImageView.image = image
    }

    func showValidationMessage(_ message: String?, isError: Bool = true) {
        validationLabel.text = message
        validationLabel.textColor = isError ? .systemRed : .systemGreen
        validationLabel.isHidden = message == nil
    }
}
