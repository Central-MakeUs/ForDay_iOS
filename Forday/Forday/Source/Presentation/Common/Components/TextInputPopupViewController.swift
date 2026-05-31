//
//  TextInputPopupViewController.swift
//  Forday
//
//  Created by Subeen on 2/6/26.
//

import UIKit
import SnapKit
import Then

class TextInputPopupViewController: UIViewController {

    // MARK: - Properties

    var onSubmit: ((String) -> Void)?
    var initialText: String?

    private let popupTitle: String
    private let placeholderText: String
    private let maxCharacterCount: Int
    private var dialogCenterYConstraint: Constraint?

    // MARK: - UI Components

    private let dimView = UIView()
    private let dialogView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let textField = UITextField()
    private let underlineView = UIView()
    private let characterCountLabel = UILabel()
    private let submitButton = UIButton(type: .system)

    // MARK: - Initialization

    init(title: String, placeholder: String, maxCharacterCount: Int = 10) {
        self.popupTitle = title
        self.placeholderText = placeholder
        self.maxCharacterCount = maxCharacterCount
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupActions()
        if let initialText {
            textField.text = initialText
        }
        updateSubmitButtonState()
        updateCharacterCount()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
}

// MARK: - Setup

extension TextInputPopupViewController {
    private func style() {
        view.backgroundColor = .clear

        dimView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }

        dialogView.do {
            $0.backgroundColor = .neutral50
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }

        titleLabel.do {
            $0.setTextWithTypography(popupTitle, style: .header18)
            $0.textColor = .neutral900
        }

        closeButton.do {
            $0.setImage(.Icon.closeRound, for: .normal)
            $0.tintColor = .neutral900
        }

        textField.do {
            $0.placeholder = placeholderText
            $0.font = TypographyStyle.label14.font
            $0.textColor = .neutral900
            $0.clearButtonMode = .whileEditing
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }

        underlineView.do {
            $0.backgroundColor = .neutral400
        }

        characterCountLabel.do {
            $0.setTextWithTypography("0/\(maxCharacterCount)", style: .label10)
            $0.textColor = .neutral400
            $0.textAlignment = .right
        }

        submitButton.do {
            $0.setTitle("확인", for: .normal)
            $0.titleLabel?.applyTypography(.header14)
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
    }

    private func layout() {
        view.addSubview(dimView)
        view.addSubview(dialogView)
        dialogView.addSubview(titleLabel)
        dialogView.addSubview(closeButton)
        dialogView.addSubview(textField)
        dialogView.addSubview(underlineView)
        dialogView.addSubview(characterCountLabel)
        dialogView.addSubview(submitButton)

        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        dialogView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            dialogCenterYConstraint = $0.centerY.equalToSuperview().constraint
            $0.width.equalTo(312)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(24)
        }

        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-24)
            $0.size.equalTo(24)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(36)
        }

        underlineView.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(1)
        }

        characterCountLabel.snp.makeConstraints {
            $0.top.equalTo(underlineView.snp.bottom).offset(6)
            $0.trailing.equalToSuperview().offset(-24)
        }

        submitButton.snp.makeConstraints {
            $0.top.equalTo(characterCountLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupActions() {
        let dimTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        dimView.addGestureRecognizer(dimTapGesture)

        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - Actions

extension TextInputPopupViewController {
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let keyboardHeight = keyboardFrame.height
        let offset = -(keyboardHeight / 2)
        dialogCenterYConstraint?.update(offset: offset)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        dialogCenterYConstraint?.update(offset: 0)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func dismissPopup() {
        dismiss(animated: true)
    }

    @objc private func submitTapped() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        onSubmit?(text.trimmingCharacters(in: .whitespaces))
        dismiss(animated: true)
    }

    @objc private func textFieldDidChange() {
        updateSubmitButtonState()
        updateCharacterCount()
    }

    private func updateSubmitButtonState() {
        let hasText = !(textField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        submitButton.isEnabled = hasText
        submitButton.backgroundColor = hasText ? .action001 : .action003
    }

    private func updateCharacterCount() {
        let count = textField.text?.count ?? 0
        characterCountLabel.setTextWithTypography("\(count)/\(maxCharacterCount)", style: .label10)
        characterCountLabel.textColor = .neutral400
    }
}

// MARK: - UITextFieldDelegate

extension TextInputPopupViewController: UITextFieldDelegate {
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
