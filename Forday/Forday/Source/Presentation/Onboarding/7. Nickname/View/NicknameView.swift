//
//  NicknameView.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import UIKit
import SnapKit
import Then

class NicknameView: UIView {

    // Properties

    private let contentView = UIView()

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    let inputContainerView = UIView()
    let nicknameLabel = UILabel()
    let nicknameTextField = UITextField()
    let duplicateCheckButton = UIButton()

    let validationLabel = UILabel()

    // Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension NicknameView {
    private func style() {
        backgroundColor = .neutralWhite
        
        titleLabel.do {
            $0.setTextWithTypography("뉴 포비님,\n어떻게 불리면 좋을까요?", style: .header24)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            $0.setTextWithTypography("포데이에서는 사용자를 '포비'라고 불러요.\n포비님의 이름을 알려주세요.", style: .label14)
            $0.textColor = .neutral600
            $0.numberOfLines = 0
        }
        
        inputContainerView.do {
            $0.backgroundColor = .neutral100
            $0.layer.cornerRadius = 12
        }
        
        nicknameLabel.do {
            $0.setTextWithTypography("닉네임", style: .label12)
            $0.textColor = .neutral500
        }
        
        nicknameTextField.do {
            $0.placeholder = "포비님의 닉네임을 입력해주세요."
            $0.font = TypographyStyle.header18.font
            $0.textColor = .neutral900
            $0.borderStyle = .none
            $0.clearButtonMode = .whileEditing
            $0.autocorrectionType = .no
            $0.autocapitalizationType = .none
            $0.spellCheckingType = .no

            // 버튼이 우선적으로 크기를 유지하도록 설정
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        
        duplicateCheckButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "중복확인"
            config.baseBackgroundColor = .neutral800
            config.baseForegroundColor = .neutralWhite
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)

            $0.configuration = config
            $0.setTitleWithTypography("중복확인", style: .label12)

            // 버튼 크기 압축 방지
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }
        
        validationLabel.do {
            $0.applyTypography(.label12)
            $0.textColor = .secondary001  // 기본 빨간색
            $0.numberOfLines = 0
            $0.isHidden = true
        }
    }
    
    private func layout() {
        addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(inputContainerView)
        contentView.addSubview(validationLabel)
        
        inputContainerView.addSubview(nicknameLabel)
        inputContainerView.addSubview(nicknameTextField)
        inputContainerView.addSubview(duplicateCheckButton)
        
        // ContentView
        contentView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(48)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.greaterThanOrEqualToSuperview()
        }
        
        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        // Input Container
        inputContainerView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview()
        }
        
        // Nickname Label
        nicknameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        
        // Nickname TextField
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(duplicateCheckButton.snp.leading).offset(-16)
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.greaterThanOrEqualTo(44)
        }
        
        // Duplicate Check Button
        duplicateCheckButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-8)
            $0.centerY.equalTo(nicknameTextField)
            $0.height.equalTo(28)
        }
        
        // Validation Label
        validationLabel.snp.makeConstraints {
            $0.top.equalTo(inputContainerView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
    }
}

// Public Methods

extension NicknameView {
    /// 유효성 검사 결과에 따른 UI 업데이트
    func updateValidationState(_ result: NicknameValidationResult) {
        // 메시지 표시
        if let message = result.message {
            validationLabel.setTextWithTypography(message, style: .label12)
            validationLabel.textColor = result.messageColor
            validationLabel.isHidden = false
        } else {
            validationLabel.isHidden = true
        }

        // 중복확인 버튼 활성화/비활성화
        duplicateCheckButton.isEnabled = result.isDuplicateCheckEnabled

        // 버튼 배경색 업데이트
        var config = duplicateCheckButton.configuration
        config?.baseBackgroundColor = result.isDuplicateCheckEnabled ? .neutral800 : .neutral400
        duplicateCheckButton.configuration = config
    }
}

#Preview {
    NicknameView()
}
