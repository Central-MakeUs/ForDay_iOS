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
        backgroundColor = .systemBackground
        
        titleLabel.do {
            $0.text = "뉴 포비님,\n어떻게 불리면 좋을까요?"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        
        subtitleLabel.do {
            $0.text = "포데이에서는 사용자를 '포비'라고 불러요.\n포비님의 이름을 알려주세요."
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 0
        }
        
        inputContainerView.do {
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 12
        }
        
        nicknameLabel.do {
            $0.text = "닉네임"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .secondaryLabel
        }
        
        nicknameTextField.do {
            $0.placeholder = "포비님의 닉네임을 입력해 주세요."
            $0.font = .systemFont(ofSize: 18, weight: .semibold)
            $0.textColor = .label
            $0.borderStyle = .none
            $0.clearButtonMode = .whileEditing
            $0.autocorrectionType = .no
            $0.autocapitalizationType = .none
            $0.spellCheckingType = .no
        }
        
        duplicateCheckButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "중복확인"
            config.baseBackgroundColor = .label
            config.baseForegroundColor = .systemBackground
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            
            $0.configuration = config
        }
        
        validationLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .systemRed
            $0.numberOfLines = 0
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
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        // Nickname TextField
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(duplicateCheckButton.snp.leading).offset(-12)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        // Duplicate Check Button
        duplicateCheckButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(nicknameTextField)
        }
        
        // Validation Label
        validationLabel.snp.makeConstraints {
            $0.top.equalTo(inputContainerView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }
    }
}

// Public Methods

extension NicknameView {
    func showValidationMessage(_ message: String?, isError: Bool = true) {
        validationLabel.text = message
        validationLabel.textColor = isError ? .systemRed : .systemGreen
        validationLabel.isHidden = message == nil
    }
}

#Preview {
    NicknameView()
}
