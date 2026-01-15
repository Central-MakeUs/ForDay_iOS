//
//  AIActivitySelectionView.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import SnapKit
import Then

class AIActivitySelectionView: UIView {
    
    // Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    
    private let activityStackView = UIStackView()
    
    private let refreshButton = UIButton()
    private let refreshCountLabel = UILabel()
    private let nextButton = UIButton()
    
    private let result: AIRecommendationResult
    private var activityViews: [ActivityItemView] = []
    private var selectedActivity: AIRecommendation?
    
    // Callbacks
    var onActivitySelected: ((AIRecommendation) -> Void)?
    var onRefreshTapped: (() -> Void)?
    
    // Initialization
    
    init(result: AIRecommendationResult) {
        self.result = result
        super.init(frame: .zero)
        style()
        layout()
        configure()
        setupActivities()
        setupActions()
        updateRefreshButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension AIActivitySelectionView {
    private func configure() {
        titleLabel.text = "\(result.message)"
    }
    
    private func style() {
        backgroundColor = .systemBackground
        
        scrollView.do {
            $0.showsVerticalScrollIndicator = false
        }
        
        iconImageView.do {
            $0.image = UIImage(systemName: "sparkles")
            $0.tintColor = .systemOrange
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.applyTypography(.header18)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        
        activityStackView.do {
            $0.axis = .vertical
            $0.spacing = 12
            $0.distribution = .fill
        }
        
        // Refresh Button
        refreshButton.do {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "arrow.clockwise")
            config.imagePadding = 8
            config.baseForegroundColor = .label
            
            $0.configuration = config
            $0.layer.cornerRadius = 20
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
        }
        
        refreshCountLabel.do {
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .label
        }
        
        // Next Button
        nextButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "다음"
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
        scrollView.addSubview(contentView)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(activityStackView)
        
        addSubview(refreshButton)
        addSubview(refreshCountLabel)
        addSubview(nextButton)
        
        // ScrollView
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(refreshButton.snp.top).offset(-16)
        }
        
        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
        }
        
        // Icon
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Activity Stack
        activityStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        // Refresh Button
        refreshButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
            $0.width.height.equalTo(40)
        }
        
        // Refresh Count
        refreshCountLabel.snp.makeConstraints {
            $0.leading.equalTo(refreshButton.snp.trailing).offset(8)
            $0.centerY.equalTo(refreshButton)
        }
        
        // Next Button
        nextButton.snp.makeConstraints {
            $0.leading.equalTo(refreshCountLabel.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
        }
    }
    
    private func setupActivities() {
        result.activities.forEach { activity in
            let activityView = ActivityItemView(activity: activity)
            activityView.onSelected = { [weak self] selectedActivity in
                self?.handleActivitySelection(selectedActivity)
            }
            activityView.onEditTapped = { [weak self] activity in
                self?.handleActivityEdit(activity)
            }
            
            activityStackView.addArrangedSubview(activityView)
            activityViews.append(activityView)
        }
    }
    
    private func setupActions() {
        refreshButton.addTarget(
            self,
            action: #selector(refreshButtonTapped),
            for: .touchUpInside
        )
        
        nextButton.addTarget(
            self,
            action: #selector(nextButtonTapped),
            for: .touchUpInside
        )
    }
    
    private func updateRefreshButton() {
        let count = result.aiCallCount
        let limit = result.aiCallLimit
        
        refreshCountLabel.text = "\(count)/\(limit)"
        refreshButton.isEnabled = count < limit
        
        if count >= limit {
            refreshButton.alpha = 0.3
        }
    }
}

// Actions

extension AIActivitySelectionView {
    private func handleActivitySelection(_ activity: AIRecommendation) {
        selectedActivity = activity
        
        // 모든 ActivityView 선택 해제
        activityViews.forEach { $0.setSelected(false) }
        
        // 선택된 ActivityView만 선택 상태로
        if let selectedView = activityViews.first(where: { $0.activity.activityId == activity.activityId }) {
            selectedView.setSelected(true)
        }
        
        // 다음 버튼 활성화
        setNextButtonEnabled(true)
    }
    
    private func handleActivityEdit(_ activity: AIRecommendation) {
        // TODO: 수정 모드 구현
        print("편집: \(activity.topic)")
    }
    
    @objc private func refreshButtonTapped() {
        onRefreshTapped?()
    }
    
    @objc private func nextButtonTapped() {
        guard let selected = selectedActivity else { return }
        onActivitySelected?(selected)
    }
    
    private func setNextButtonEnabled(_ isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        
        var config = nextButton.configuration
        config?.baseBackgroundColor = isEnabled ? .systemOrange : .systemGray4
        nextButton.configuration = config
    }
}

#Preview {
    AIActivitySelectionView(result: .stub01)
}
