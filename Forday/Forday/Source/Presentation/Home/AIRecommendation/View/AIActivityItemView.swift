//
//  AIActivityItemView.swift
//  Forday
//
//  Created by Subeen on 2/23/26.
//

import UIKit
import SnapKit
import Then

/// AI 추천 활동 리스트용 아이템 뷰
class AIActivityItemView: UIView {

    // MARK: - Properties

    private(set) var item: AIActivityItem
    private var isSelectedState = false
    private let maxContentLength = 20

    private let containerView = UIView()
    private let titleStackView = UIStackView()
    private let contentTextField = UITextField()
    private let editButton = UIButton()
    private let checkboxButton = UIButton()
    private let descriptionLabel = UILabel()

    // MARK: - Callbacks

    var onSelected: ((AIActivityItem) -> Void)?
    var onContentEdited: ((String) -> Void)?

    // MARK: - Initialization

    init(item: AIActivityItem) {
        self.item = item
        super.init(frame: .zero)
        style()
        layout()
        configure()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension AIActivityItemView {
    private func style() {
        containerView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
        }

        titleStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }

        contentTextField.do {
            $0.font = TypographyStyle.body16.font
            $0.textColor = .neutral900
            $0.isUserInteractionEnabled = false
            $0.returnKeyType = .done
            $0.delegate = self
        }

        editButton.do {
            var config = UIButton.Configuration.plain()
            config.image = .Icon.edit
            config.baseForegroundColor = .neutral500
            $0.configuration = config
        }

        checkboxButton.do {
            $0.setImage(.Onoff.checkboxFalse, for: .normal)
            $0.setImage(.Onoff.checkboxTrue, for: .selected)
        }

        descriptionLabel.do {
            $0.textColor = .neutral600
            $0.numberOfLines = 0
        }
    }

    private func layout() {
        addSubview(containerView)

        containerView.addSubview(titleStackView)
        containerView.addSubview(checkboxButton)
        containerView.addSubview(descriptionLabel)

        titleStackView.addArrangedSubview(contentTextField)
        titleStackView.addArrangedSubview(editButton)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Title Stack (content + edit button)
        titleStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualTo(checkboxButton.snp.leading).offset(-8)
        }

        // Edit Button
        editButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }

        checkboxButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(16)
            $0.width.height.equalTo(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    private func configure() {
        contentTextField.text = item.content
        descriptionLabel.setTextWithTypography(item.description, style: .label14)
    }

    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        containerView.addGestureRecognizer(tapGesture)

        editButton.addTarget(
            self,
            action: #selector(editButtonTapped),
            for: .touchUpInside
        )

        checkboxButton.addTarget(
            self,
            action: #selector(checkboxTapped),
            for: .touchUpInside
        )
    }

    @objc private func viewTapped() {
        // Dismiss keyboard if editing
        if contentTextField.isFirstResponder {
            contentTextField.resignFirstResponder()
            return
        }

        onSelected?(item)
    }

    @objc private func editButtonTapped() {
        contentTextField.isUserInteractionEnabled = true
        contentTextField.becomeFirstResponder()
    }

    @objc private func checkboxTapped() {
        onSelected?(item)
    }
}

// MARK: - UITextFieldDelegate

extension AIActivityItemView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxContentLength
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isUserInteractionEnabled = false

        // Update item content
        if let newContent = textField.text, !newContent.isEmpty {
            item = AIActivityItem(
                itemId: item.itemId,
                content: newContent,
                description: item.description
            )
            onContentEdited?(newContent)
        }
    }
}

// MARK: - Public Methods

extension AIActivityItemView {
    func setSelected(_ isSelected: Bool) {
        isSelectedState = isSelected
        checkboxButton.isSelected = isSelected
        containerView.layer.borderWidth = isSelected ? 2 : 1
        containerView.layer.borderColor = isSelected ? UIColor.systemOrange.cgColor : UIColor.stroke001.cgColor
    }

    func dismissKeyboard() {
        contentTextField.resignFirstResponder()
    }

    func getContent() -> String {
        return contentTextField.text ?? item.content
    }
}
