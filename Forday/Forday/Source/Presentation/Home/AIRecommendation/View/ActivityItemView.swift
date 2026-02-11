//
//  ActivityItemView.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import SnapKit
import Then

class ActivityItemView: UIView {

    // Properties

    private(set) var activity: AIRecommendation
    private var isSelectedState = false

    private let containerView = UIView()
    private let titleStackView = UIStackView()
    private let contentTextField = UITextField()
    private let editButton = UIButton()
    private let checkboxButton = UIButton()
    private let descriptionLabel = UILabel()

    // Callbacks
    var onSelected: ((AIRecommendation) -> Void)?
    var onContentEdited: ((String) -> Void)?

    // Initialization

    init(activity: AIRecommendation) {
        self.activity = activity
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

// Setup

extension ActivityItemView {
    private func style() {
        containerView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 12
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

        // Container
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

        // Checkbox (top right)
        checkboxButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(16)
            $0.width.height.equalTo(20)
        }

        // Description
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    private func configure() {
        contentTextField.text = activity.content
        descriptionLabel.setTextWithTypography(activity.description, style: .label14)
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

        // Select this item
        onSelected?(activity)
    }

    @objc private func editButtonTapped() {
        contentTextField.isUserInteractionEnabled = true
        contentTextField.becomeFirstResponder()
    }

    @objc private func checkboxTapped() {
        onSelected?(activity)
    }
}

// UITextFieldDelegate

extension ActivityItemView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isUserInteractionEnabled = false

        // Update activity content
        if let newContent = textField.text, !newContent.isEmpty {
            activity = AIRecommendation(
                activityId: activity.activityId,
                topic: activity.topic,
                content: newContent,
                description: activity.description
            )
            onContentEdited?(newContent)
        }
    }
}

// Public Methods

extension ActivityItemView {
    func setSelected(_ isSelected: Bool) {
        isSelectedState = isSelected
        checkboxButton.isSelected = isSelected
        containerView.layer.borderWidth = isSelected ? 2 : 0
        containerView.layer.borderColor = isSelected ? UIColor.systemOrange.cgColor : UIColor.clear.cgColor
    }

    func setEditEnabled(_ isEnabled: Bool) {
        editButton.isHidden = !isEnabled
    }

    func dismissKeyboard() {
        contentTextField.resignFirstResponder()
    }

    func getContent() -> String {
        return contentTextField.text ?? activity.content
    }
}
