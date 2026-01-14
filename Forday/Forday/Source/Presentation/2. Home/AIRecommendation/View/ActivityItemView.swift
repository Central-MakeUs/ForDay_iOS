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
    
    let activity: AIRecommendation
    
    private let containerView = UIView()
    private let checkboxButton = UIButton()
    private let topicLabel = UILabel()
    private let editButton = UIButton()
    private let descriptionLabel = UILabel()
    
    // Callbacks
    var onSelected: ((AIRecommendation) -> Void)?
    var onEditTapped: ((AIRecommendation) -> Void)?
    
    // Initialization
    
    init(activity: AIRecommendation) {
        self.activity = activity
        super.init(frame: .zero)
        style()
        layout()
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
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 12
        }
        
        checkboxButton.do {
            $0.setImage(UIImage(systemName: "circle"), for: .normal)
            $0.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
            $0.tintColor = .systemGray4
        }
        
        topicLabel.do {
            $0.text = activity.topic
            $0.font = .systemFont(ofSize: 16, weight: .bold)
            $0.textColor = .label
        }
        
        editButton.do {
            $0.setImage(UIImage(systemName: "pencil"), for: .normal)
            $0.tintColor = .systemGray
        }
        
        descriptionLabel.do {
            $0.text = activity.description
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 0
        }
    }
    
    private func layout() {
        addSubview(containerView)
        
        containerView.addSubview(checkboxButton)
        containerView.addSubview(topicLabel)
        containerView.addSubview(editButton)
        containerView.addSubview(descriptionLabel)
        
        // Container
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // Checkbox
        checkboxButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
            $0.width.height.equalTo(24)
        }
        
        // Topic
        topicLabel.snp.makeConstraints {
            $0.leading.equalTo(checkboxButton.snp.trailing).offset(12)
            $0.trailing.equalTo(editButton.snp.leading).offset(-8)
            $0.centerY.equalTo(checkboxButton)
        }
        
        // Edit
        editButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(checkboxButton)
            $0.width.height.equalTo(24)
        }
        
        // Description
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(topicLabel.snp.bottom).offset(8)
            $0.leading.equalTo(topicLabel)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        containerView.addGestureRecognizer(tapGesture)
        
        editButton.addTarget(
            self,
            action: #selector(editButtonTapped),
            for: .touchUpInside
        )
    }
    
    @objc private func viewTapped() {
        onSelected?(activity)
    }
    
    @objc private func editButtonTapped() {
        onEditTapped?(activity)
    }
}

// Public Methods

extension ActivityItemView {
    func setSelected(_ isSelected: Bool) {
        checkboxButton.isSelected = isSelected
        checkboxButton.tintColor = isSelected ? .systemOrange : .systemGray4
        containerView.layer.borderWidth = isSelected ? 2 : 0
        containerView.layer.borderColor = isSelected ? UIColor.systemOrange.cgColor : UIColor.clear.cgColor
    }
}
