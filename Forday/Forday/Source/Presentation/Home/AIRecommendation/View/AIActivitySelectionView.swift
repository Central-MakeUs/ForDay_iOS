//
//  AIActivitySelectionView.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import SnapKit
import Then
import Combine

class AIActivitySelectionView: UIView {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    private let activityStackView = UIStackView()

    private let refreshButton = UIButton()
    private let refreshCountLabel = UILabel()
    private let nextButton = UIButton()

    // Skeleton Views
    private let iconSkeleton = SkeletonView()
    private let titleSkeleton1 = SkeletonView()
    private let titleSkeleton2 = SkeletonView()
    private let skeletonStackView = UIStackView()
    private var activitySkeletons: [ActivityItemSkeletonView] = []

    // MARK: - Properties

    private var result: AIRecommendationResult
    private let hobbyId: Int?
    private let createActivitiesUseCase: CreateActivitiesUseCase?

    private var activityViews: [ActivityItemView] = []
    private var selectedActivityView: ActivityItemView?
    private var isSkeletonVisible = false

    // Callbacks
    /// 저장 모드: hobbyId가 있을 때 CreateActivitiesUseCase로 저장 후 호출
    var onActivitySaved: (() -> Void)?
    /// 선택 모드: 선택된 활동 content를 반환 (저장하지 않음)
    var onActivitySelected: ((String) -> Void)?
    var onRefreshTapped: (() -> Void)?
    var onError: ((String) -> Void)?

    // Initialization

    /// 저장 모드: hobbyId를 전달하면 다음 버튼 클릭 시 바로 저장
    init(
        result: AIRecommendationResult,
        hobbyId: Int,
        createActivitiesUseCase: CreateActivitiesUseCase = CreateActivitiesUseCase()
    ) {
        self.result = result
        self.hobbyId = hobbyId
        self.createActivitiesUseCase = createActivitiesUseCase
        super.init(frame: .zero)
        style()
        layout()
        configure()
        setupActivities()
        setupActions()
        updateRefreshButton()
        setupKeyboardDismissal()
    }

    /// 선택 모드: hobbyId 없이 생성하면 다음 버튼 클릭 시 onActivitySelected 콜백으로 content 반환
    init(result: AIRecommendationResult) {
        self.result = result
        self.hobbyId = nil
        self.createActivitiesUseCase = nil
        super.init(frame: .zero)
        style()
        layout()
        configure()
        setupActivities()
        setupActions()
        updateRefreshButton()
        setupKeyboardDismissal()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension AIActivitySelectionView {
    private func configure() {
        titleLabel.setTextWithTypography(result.recommendedText, style: .header18)
    }

    private func style() {
        backgroundColor = .bg001

        scrollView.do {
            $0.showsVerticalScrollIndicator = false
            $0.keyboardDismissMode = .onDrag
        }

        iconImageView.do {
            $0.image = .Ai.default
            $0.tintColor = .systemOrange
            $0.contentMode = .scaleAspectFit
        }

        titleLabel.do {
            $0.textColor = .neutral900
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }

        activityStackView.do {
            $0.axis = .vertical
            $0.spacing = 12
            $0.distribution = .fill
        }

        // Skeleton styles
        iconSkeleton.do {
            $0.layer.cornerRadius = 30
            $0.isHidden = true
        }

        titleSkeleton1.do {
            $0.layer.cornerRadius = 4
            $0.isHidden = true
        }

        titleSkeleton2.do {
            $0.layer.cornerRadius = 4
            $0.isHidden = true
        }

        skeletonStackView.do {
            $0.axis = .vertical
            $0.spacing = 12
            $0.distribution = .fill
            $0.isHidden = true
        }

        // Setup skeleton items
        setupSkeletonItems()

        refreshButton.do {
            var config = UIButton.Configuration.plain()
            config.image = .Icon.reload
            config.baseForegroundColor = .neutral800

            $0.configuration = config
            $0.backgroundColor = .bg001
            $0.layer.cornerRadius = 28 // 56/2
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.neutral200.cgColor
        }

        refreshCountLabel.do {
            $0.textColor = .neutral500
            $0.textAlignment = .center
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

    private func setupSkeletonItems() {
        // Create 3 skeleton items
        for _ in 0..<3 {
            let skeleton = ActivityItemSkeletonView()
            activitySkeletons.append(skeleton)
            skeletonStackView.addArrangedSubview(skeleton)
        }
    }

    private func layout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(activityStackView)

        // Skeleton views
        contentView.addSubview(iconSkeleton)
        contentView.addSubview(titleSkeleton1)
        contentView.addSubview(titleSkeleton2)
        contentView.addSubview(skeletonStackView)

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

        // Icon Skeleton
        iconSkeleton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }

        // Title Skeletons
        titleSkeleton1.snp.makeConstraints {
            $0.top.equalTo(iconSkeleton.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(20)
        }

        titleSkeleton2.snp.makeConstraints {
            $0.top.equalTo(titleSkeleton1.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(20)
        }

        // Skeleton Stack
        skeletonStackView.snp.makeConstraints {
            $0.top.equalTo(titleSkeleton2.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }

        refreshButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
            $0.width.height.equalTo(56)
        }

        // Refresh Count
        refreshCountLabel.snp.makeConstraints {
            $0.centerX.equalTo(refreshButton)
            $0.top.equalTo(refreshButton.snp.bottom).offset(4)
        }

        // Next Button
        nextButton.snp.makeConstraints {
            $0.leading.equalTo(refreshButton.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(refreshButton)
        }
    }

    private func setupActivities() {
        // Selection mode: hobbyId가 nil이면 edit 버튼 숨김
        let isSelectionMode = (hobbyId == nil)

        result.activities.forEach { activity in
            let activityView = ActivityItemView(activity: activity)
            activityView.onSelected = { [weak self] _ in
                self?.handleActivitySelection(activityView)
            }

            // Selection mode에서는 edit 버튼 숨김
            if isSelectionMode {
                activityView.setEditEnabled(false)
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

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }

    private func updateRefreshButton() {
        let count = result.aiCallCount
        let limit = result.aiCallLimit

        refreshCountLabel.setTextWithTypography("\(count)/\(limit)", style: .label12)

        let isEnabled = count < limit
        refreshButton.isEnabled = isEnabled

        if isEnabled {
            refreshButton.alpha = 1.0
            refreshButton.layer.borderColor = UIColor.neutral200.cgColor
        } else {
            refreshButton.alpha = 0.5
            refreshButton.layer.borderColor = UIColor.neutral300.cgColor
        }
    }
}

// Actions

extension AIActivitySelectionView {
    private func handleActivitySelection(_ activityView: ActivityItemView) {
        // Dismiss keyboard first
        dismissKeyboard()

        // Deselect all
        activityViews.forEach { $0.setSelected(false) }

        // Select the tapped view
        activityView.setSelected(true)
        selectedActivityView = activityView

        // Enable next button
        setNextButtonEnabled(true)
    }

    @objc private func dismissKeyboard() {
        activityViews.forEach { $0.dismissKeyboard() }
    }

    @objc private func refreshButtonTapped() {
        showSkeleton()
        onRefreshTapped?()
    }

    @objc private func nextButtonTapped() {
        guard let selectedView = selectedActivityView else { return }

        // Get the (possibly edited) content from the selected view
        let content = selectedView.getContent()

        // 선택 모드: onActivitySelected가 설정되어 있으면 content만 반환 (저장 안함)
        if let onActivitySelected = onActivitySelected {
            onActivitySelected(content)
            return
        }

        // 저장 모드: hobbyId와 createActivitiesUseCase가 있어야 함
        guard let hobbyId = hobbyId,
              let createActivitiesUseCase = createActivitiesUseCase else {
            return
        }

        // Create activity input
        let activityInput = ActivityInput(aiRecommended: true, content: content)

        // Disable button during save
        nextButton.isEnabled = false

        // Save using use case
        Task {
            do {
                _ = try await createActivitiesUseCase.execute(
                    hobbyId: hobbyId,
                    activities: [activityInput]
                )

                await MainActor.run {
                    // 홈 화면 업데이트를 위한 이벤트 발생
                    AppEventBus.shared.activityRecordCreated.send(hobbyId)
                    onActivitySaved?()
                }
            } catch {
                await MainActor.run {
                    setNextButtonEnabled(true)
                    onError?(error.localizedDescription)
                }
            }
        }
    }

    private func setNextButtonEnabled(_ isEnabled: Bool) {
        nextButton.isEnabled = isEnabled

        var config = nextButton.configuration
        config?.baseBackgroundColor = isEnabled ? .systemOrange : .systemGray4
        nextButton.configuration = config
    }
}

// MARK: - Skeleton

extension AIActivitySelectionView {
    func showSkeleton() {
        guard !isSkeletonVisible else { return }
        isSkeletonVisible = true

        // Hide actual content
        iconImageView.isHidden = true
        titleLabel.isHidden = true
        activityStackView.isHidden = true

        // Show skeleton views
        iconSkeleton.isHidden = false
        titleSkeleton1.isHidden = false
        titleSkeleton2.isHidden = false
        skeletonStackView.isHidden = false

        // Start animations
        iconSkeleton.startAnimating()
        titleSkeleton1.startAnimating()
        titleSkeleton2.startAnimating()
        activitySkeletons.forEach { $0.startAnimating() }

        // Disable next button during loading
        setNextButtonEnabled(false)
    }

    func hideSkeleton() {
        guard isSkeletonVisible else { return }
        isSkeletonVisible = false

        // Stop animations
        iconSkeleton.stopAnimating()
        titleSkeleton1.stopAnimating()
        titleSkeleton2.stopAnimating()
        activitySkeletons.forEach { $0.stopAnimating() }

        // Hide skeleton views
        iconSkeleton.isHidden = true
        titleSkeleton1.isHidden = true
        titleSkeleton2.isHidden = true
        skeletonStackView.isHidden = true

        // Show actual content
        iconImageView.isHidden = false
        titleLabel.isHidden = false
        activityStackView.isHidden = false
    }

    func update(with newResult: AIRecommendationResult) {
        // Update result
        self.result = newResult

        // Clear existing activity views
        activityViews.forEach { $0.removeFromSuperview() }
        activityViews.removeAll()
        selectedActivityView = nil

        // Update UI
        configure()
        setupActivities()
        updateRefreshButton()

        // Hide skeleton
        hideSkeleton()
    }
}

#Preview("Save Mode") {
    AIActivitySelectionView(result: .stub01, hobbyId: 1)
}

#Preview("Select Mode") {
    AIActivitySelectionView(result: .stub01)
}
