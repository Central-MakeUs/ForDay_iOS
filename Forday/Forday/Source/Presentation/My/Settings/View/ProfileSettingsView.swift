//
//  ProfileSettingsView.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit
import SnapKit
import Then

final class ProfileSettingsView: UIView {

    // MARK: - UI Components

    // Custom Navigation Bar
    private let navigationBarView = UIView()
    let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    let completeButton = UIButton(type: .system)

    // Profile Image Section
    private let profileContainerView = UIView()
    let profileImageView = UIImageView()
    let cameraIconView = UIImageView()

    // Nickname Input Section
    private let inputContainerView = UIView()
    private let nicknameLabel = UILabel()
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

extension ProfileSettingsView {
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
            $0.setTextWithTypography("내 프로필 설정", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        completeButton.do {
            $0.setTitle("완료", for: .normal)
            $0.setTitleColor(.neutral900, for: .normal)
            $0.setTitleColor(.neutral400, for: .disabled)
            $0.titleLabel?.font = TypographyStyle.body14.font
            $0.isEnabled = false
        }

        // Profile Image
        profileImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 40
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.image = .Icon.defaultProfile
            $0.isUserInteractionEnabled = true
        }

        cameraIconView.do {
            $0.image = .Icon.cameraCircle
            $0.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = true
        }

        // Input Container
        inputContainerView.do {
            $0.backgroundColor = .neutral50
            $0.layer.cornerRadius = 12
        }

        nicknameLabel.do {
            $0.setTextWithTypography("닉네임", style: .label12)
            $0.textColor = .neutral500
        }

        nicknameTextField.do {
            $0.placeholder = "닉네임을 입력해 주세요."
            $0.font = TypographyStyle.header16.font
            $0.textColor = .neutral900
            $0.borderStyle = .none
            $0.clearButtonMode = .never
            $0.autocorrectionType = .no
            $0.autocapitalizationType = .none
            $0.spellCheckingType = .no
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }

        duplicateCheckButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "중복확인"
            config.baseBackgroundColor = .neutral900
            config.baseForegroundColor = .neutralWhite
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)

            $0.configuration = config
            $0.setTitleWithTypography("중복확인", style: .label12)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        validationLabel.do {
            $0.applyTypography(.label12)
            $0.textColor = .secondary001
            $0.numberOfLines = 0
            $0.isHidden = true
        }
    }

    private func layout() {
        addSubview(navigationBarView)
        navigationBarView.addSubview(backButton)
        navigationBarView.addSubview(titleLabel)
        navigationBarView.addSubview(completeButton)

        addSubview(profileContainerView)
        profileContainerView.addSubview(profileImageView)
        profileContainerView.addSubview(cameraIconView)

        addSubview(inputContainerView)
        inputContainerView.addSubview(nicknameLabel)
        inputContainerView.addSubview(nicknameTextField)
        inputContainerView.addSubview(duplicateCheckButton)

        addSubview(validationLabel)

        // Navigation Bar
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

        completeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }

        // Profile Container
        profileContainerView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        profileImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        cameraIconView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
            $0.width.height.equalTo(24)
        }

        // Input Container
        inputContainerView.snp.makeConstraints {
            $0.top.equalTo(profileContainerView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(60)
        }

        nicknameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
        }

        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(duplicateCheckButton.snp.leading).offset(-16)
            $0.bottom.equalToSuperview().offset(-8)
        }

        duplicateCheckButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(nicknameTextField)
            $0.height.equalTo(28)
        }

        // Validation Label
        validationLabel.snp.makeConstraints {
            $0.top.equalTo(inputContainerView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(36)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}

// MARK: - Public Methods

extension ProfileSettingsView {
    /// Update profile image
    func updateProfileImage(_ image: UIImage?) {
        if let image = image {
            profileImageView.image = image
        } else {
            profileImageView.image = .Icon.defaultProfile
        }
    }

    /// Update validation state
    func updateValidationState(_ result: NicknameValidationResult) {
        // Show message
        if let message = result.message {
            validationLabel.setTextWithTypography(message, style: .label12)
            validationLabel.textColor = result.messageColor
            validationLabel.isHidden = false
        } else {
            validationLabel.isHidden = true
        }

        // Update duplicate check button
        duplicateCheckButton.isEnabled = result.isDuplicateCheckEnabled

        var config = duplicateCheckButton.configuration
        config?.baseBackgroundColor = result.isDuplicateCheckEnabled ? .neutral900 : .neutral400
        duplicateCheckButton.configuration = config
    }

    /// Update complete button state
    func updateCompleteButtonState(isEnabled: Bool) {
        completeButton.isEnabled = isEnabled
    }
}

#if DEBUG
#Preview {
    ProfileSettingsView()
}
#endif
