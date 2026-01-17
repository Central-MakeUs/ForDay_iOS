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
    private let recommendationLabel = UILabel()
    private let flowLayoutView = FlowLayoutView()
    private let saveButton = UIButton()

    private var activityFields: [ActivityInputField] = []
    private let maxFields = 3

    // Callbacks
    var onSaveButtonTapped: (() -> Void)?
    var onAddButtonTapped: (() -> Void)?
    var onDeleteButtonTapped: ((Int) -> Void)?
    var onRecommendationButtonTapped: ((String) -> Void)?
    
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

        recommendationLabel.do {
            $0.setTextWithTypography("다른 포비들은 이런 활동을 하고 있어요", style: .body14)
            $0.textColor = .neutral800
        }

        flowLayoutView.do {
            $0.onButtonTapped = { [weak self] title in
                self?.onRecommendationButtonTapped?(title)
            }
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
        contentView.addSubview(recommendationLabel)
        contentView.addSubview(flowLayoutView)
        
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
        }

        // Recommendation Label
        recommendationLabel.snp.makeConstraints {
            $0.top.equalTo(addButton.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // FlowLayout View
        flowLayoutView.snp.makeConstraints {
            $0.top.equalTo(recommendationLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(100) // 초기 높이, 버튼 추가 시 업데이트됨
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
        guard activityFields.count < maxFields else { return }

        let field = ActivityInputField(type: .userInput)
        field.onDeleteTapped = { [weak self] in
            guard let self = self,
                  let index = self.activityFields.firstIndex(of: field) else { return }
            self.onDeleteButtonTapped?(index)
        }

        field.onTextChanged = { [weak self] _ in
            self?.updateAddButtonVisibility()
        }

        activityFields.append(field)
        stackView.addArrangedSubview(field)

        updateAddButtonVisibility()
    }
    
    func deleteActivityField(at index: Int) {
        guard index < activityFields.count else { return }

        let field = activityFields[index]
        stackView.removeArrangedSubview(field)
        field.removeFromSuperview()
        activityFields.remove(at: index)

        updateAddButtonVisibility()
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

    func setRecommendations(_ activities: [OthersActivity]) {
        let titles = activities.map { $0.content }
        flowLayoutView.configure(with: titles)
    }

    func fillLastFieldWithText(_ text: String) {
        guard let lastField = activityFields.last else { return }
        lastField.setText(text)
        updateAddButtonVisibility()
    }

    private func updateAddButtonVisibility() {
        // 3개 도달 → addButton 숨김
        if activityFields.count >= maxFields {
            addButton.isHidden = true
            return
        }

        // 마지막 필드에 텍스트가 있으면 addButton 표시
        if let lastField = activityFields.last {
            addButton.isHidden = lastField.getText().isEmpty
        } else {
            addButton.isHidden = false
        }
    }
}

#Preview {
    HobbyActivityInputView()
}
