//
//  ActivityInputField.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import UIKit
import SnapKit
import Then

class ActivityInputField: UIView {
    
    // Properties
    
    private(set) var type: ActivityInputType = .userInput
    
    private let containerView = UIView()
    private let aiImageView = UIImageView()
    let textField = UITextField()
    let deleteButton = UIButton()
    private let characterCountLabel = UILabel()
    
    private let maxCharacterCount = 20
    
    // Callbacks
    var onDelete: (() -> Void)?
    var onTextChanged: ((String) -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    // Initialization
    
    init(type: ActivityInputType = .userInput) {
        self.type = type
        super.init(frame: .zero)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension ActivityInputField {
    
    private func style() {
        containerView.do {
            $0.backgroundColor = .neutral100
            $0.layer.cornerRadius = 12
        }
        
        aiImageView.do {
            $0.image = .Ai.aiRecommeded
            $0.contentMode = .scaleAspectFit
            $0.isHidden = type == .userInput
        }
        
        textField.do {
            $0.placeholder = "포비님의 취미활동을 적어주세요"
            $0.font = .systemFont(ofSize: 16, weight: .regular)
            $0.textColor = .label
            $0.borderStyle = .none
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        deleteButton.do {
            $0.setImage(UIImage(systemName: "trash"), for: .normal)
            $0.tintColor = .systemGray3
            $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        }
        
        characterCountLabel.do {
            $0.text = "0/\(maxCharacterCount)"
            $0.font = .systemFont(ofSize: 12, weight: .regular)
            $0.textColor = .systemGray3
        }
    }
    
    private func layout() {
        addSubview(containerView)

        containerView.addSubview(aiImageView)
        containerView.addSubview(textField)
        containerView.addSubview(deleteButton)
        containerView.addSubview(characterCountLabel)

        // Container
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // AI Image
        aiImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(20)
        }

        // TextField
        textField.snp.makeConstraints {
            if type == .aiRecommended {
                $0.top.equalTo(aiImageView.snp.bottom).offset(4)
            } else {
                $0.top.equalToSuperview().offset(12)
            }
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            $0.height.greaterThanOrEqualTo(44)
        }
        
        // Delete Button
        deleteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(24)
        }
        
        // Character Count
        characterCountLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}

// Actions

extension ActivityInputField {
    
    private func setupActions() {
        deleteButton.addTarget(
            self,
            action: #selector(deleteButtonTapped),
            for: .touchUpInside
        )
    }
    
    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }
    
    @objc private func textFieldDidChange() {
        updateCharacterCount()
        onTextChanged?(textField.text ?? "")
    }
    
    private func updateCharacterCount() {
        let count = textField.text?.count ?? 0
        characterCountLabel.text = "\(count)/\(maxCharacterCount)"
        characterCountLabel.textColor = count > maxCharacterCount ? .systemRed : .systemGray3
    }
}

// Public Methods

extension ActivityInputField {
    func configure(type: ActivityInputType, text: String = "") {
        self.type = type

        aiImageView.isHidden = (type == .userInput)
        textField.text = text
        updateCharacterCount()

        // Layout 다시
        textField.snp.remakeConstraints {
            if type == .aiRecommended {
                $0.top.equalTo(aiImageView.snp.bottom).offset(4)
            } else {
                $0.top.equalToSuperview().offset(12)
            }
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            $0.height.greaterThanOrEqualTo(44)
        }
    }
    
    func getText() -> String {
        return textField.text ?? ""
    }

    func setText(_ text: String) {
        textField.text = text
        updateCharacterCount()
        onTextChanged?(text)
    }

    func clear() {
        textField.text = ""
        updateCharacterCount()
    }

}

// UITextFieldDelegate

extension ActivityInputField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= maxCharacterCount
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

#Preview {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 12
    stackView.distribution = .fill
    
    let userInputField = ActivityInputField(type: .userInput)
    let aiField = ActivityInputField(type: .aiRecommended)
    aiField.configure(type: .aiRecommended, text: "문단 1개 소리내서 읽기")
    
    stackView.addArrangedSubview(userInputField)
    stackView.addArrangedSubview(aiField)
    
    return stackView
}
