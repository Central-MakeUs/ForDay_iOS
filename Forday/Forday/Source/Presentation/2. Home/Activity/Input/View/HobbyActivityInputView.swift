//
//  HobbyActivityInputView.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import UIKit
import SnapKit
import Then

class HobbyActivityInputView: UIView {
    
    // Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let imageView = UIImageView()
    private let titleView = UILabel()
    private let stackView = UIStackView()
    private let addButton = UIButton()
    private let saveButton = UIButton()
    
    private var activityFields: [ActivityInputField] = []
    
    // Callbacks
    var onSaveButtonTapped: (() -> Void)?
    var onAddButtonTapped: (() -> Void)?
    var onDeleteButtonTapped: ((Int) -> Void)?
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupActions()
        
        // 초기 필드 1개 추가
        addActivityField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension HobbyActivityInputView {
    private func style() {
        backgroundColor = .systemBackground
        
        scrollView.do {
            $0.showsVerticalScrollIndicator = false
        }
        
        imageView.do {
            $0.image = .My.profileMy
            $0.contentMode = .scaleAspectFill
        }
        
        titleView.do {
            $0.setTextWithTypography("하고 싶은 취미활동을 직접 적어주세요.", style: .header20)
            $0.textColor = .neutral900
        }
        
        stackView.do {
            $0.axis = .vertical
            $0.spacing = 16
            $0.distribution = .fill
        }
        
        addButton.do {
            var config = UIButton.Configuration.plain()
            config.image = .Icon.activityAddButton
            $0.configuration = config
        }
        
        saveButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "저장"
            config.baseBackgroundColor = .systemGray4
            config.baseForegroundColor = .white
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
            
            $0.configuration = config
            $0.isEnabled = false
        }
    }
    
    private func layout() {
        addSubview(scrollView)
        addSubview(saveButton)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleView)
        contentView.addSubview(stackView)
        contentView.addSubview(addButton)
        
        // ScrollView
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalTo(saveButton.snp.top).offset(-16)
        }
        
        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.centerX.equalToSuperview()
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        // StackView
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Add Button
        addButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        // Save Button
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
        }
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addButtonTapped() {
        onAddButtonTapped?()
    }
    
    @objc private func saveButtonTapped() {
        onSaveButtonTapped?()
    }
}

// Public Methods

extension HobbyActivityInputView {
    func addActivityField() {
        let field = ActivityInputField(type: .userInput)
        field.onDeleteTapped = { [weak self] in
            guard let self = self,
                  let index = self.activityFields.firstIndex(of: field) else { return }
            self.onDeleteButtonTapped?(index)
        }
        
        activityFields.append(field)
        stackView.addArrangedSubview(field)
    }
    
    func deleteActivityField(at index: Int) {
        guard index < activityFields.count else { return }
        
        let field = activityFields[index]
        stackView.removeArrangedSubview(field)
        field.removeFromSuperview()
        activityFields.remove(at: index)
    }
    
    func getActivities() -> [(content: String, aiRecommended: Bool)] {
        return activityFields.compactMap {
            let content = $0.getText()
            guard !content.isEmpty else { return nil }
            return (content, false)
        }
    }
    
    func setSaveButtonEnabled(_ isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
        
        var config = saveButton.configuration
        config?.baseBackgroundColor = isEnabled ? .systemOrange : .systemGray4
        saveButton.configuration = config
    }
}

#Preview {
    HobbyActivityInputView()
}
