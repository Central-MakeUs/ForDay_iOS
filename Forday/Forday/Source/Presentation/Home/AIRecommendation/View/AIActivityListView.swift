//
//  AIActivityListView.swift
//  Forday
//
//  Created by Subeen on 2/23/26.
//

import UIKit
import SnapKit
import Then
import Combine

/// AI 추천 받은 활동 리스트 화면
class AIActivityListView: UIView {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let iconImageView = UIImageView()

    // Title Area
    private let titleLabel = UILabel()

    private let activityStackView = UIStackView()

    // Bottom Button
    private let bottomContainerView = UIView()
    private let saveButton = UIButton()

    // Skeleton Views
    private let iconSkeleton = SkeletonView()
    private let titleSkeleton = SkeletonView()
    private let skeletonStackView = UIStackView()
    private var activitySkeletons: [ActivityItemSkeletonView] = []

    // MARK: - Properties

    private var result: AIActivityItemsResult?
    private let hobbyId: Int
    private let createActivitiesUseCase: CreateActivitiesUseCase

    private var itemViews: [AIActivityItemView] = []
    private var selectedItemView: AIActivityItemView?
    private var isSkeletonVisible = true

    // MARK: - Callbacks

    /// 활동 저장 완료 시 호출 (바텀시트 닫지 않음)
    var onActivitySaved: (() -> Void)?
    var onError: ((String) -> Void)?
    /// 토스트 "이동하기" 버튼 클릭 시 ActivityList로 이동
    var onNavigateToActivityList: (() -> Void)?

    // MARK: - Initialization

    init(
        hobbyId: Int,
        createActivitiesUseCase: CreateActivitiesUseCase = CreateActivitiesUseCase()
    ) {
        self.hobbyId = hobbyId
        self.createActivitiesUseCase = createActivitiesUseCase
        super.init(frame: .zero)
        style()
        layout()
        setupActions()
        setupKeyboardDismissal()
        showSkeleton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension AIActivityListView {
    private func style() {
        backgroundColor = .neutralWhite

        scrollView.do {
            $0.showsVerticalScrollIndicator = false
            $0.keyboardDismissMode = .onDrag
            $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }

        iconImageView.do {
            $0.image = .Ai.default
            $0.tintColor = .systemOrange
            $0.contentMode = .scaleAspectFit
        }

        titleLabel.do {
            $0.textColor = .neutral900
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        activityStackView.do {
            $0.axis = .vertical
            $0.spacing = 10
            $0.distribution = .fill
            $0.alignment = .fill
        }

        // Skeleton styles
        iconSkeleton.do {
            $0.layer.cornerRadius = 21
        }

        titleSkeleton.do {
            $0.layer.cornerRadius = 4
        }

        skeletonStackView.do {
            $0.axis = .vertical
            $0.spacing = 10
            $0.distribution = .fill
        }

        setupSkeletonItems()

        // Save Button
        saveButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "활동 담기"
            config.baseBackgroundColor = .systemGray4
            config.baseForegroundColor = .white
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)

            $0.configuration = config
            $0.isEnabled = false
        }
    }

    private func setupSkeletonItems() {
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
        contentView.addSubview(titleSkeleton)
        contentView.addSubview(skeletonStackView)

        // Bottom button
        addSubview(saveButton)

        // ScrollView
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(saveButton.snp.top).offset(-16)
        }

        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        // Icon
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(42)
        }

        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // Activity Stack
        activityStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }

        // Icon Skeleton
        iconSkeleton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(42)
        }

        // Title Skeleton
        titleSkeleton.snp.makeConstraints {
            $0.top.equalTo(iconSkeleton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(20)
        }

        // Skeleton Stack
        skeletonStackView.snp.makeConstraints {
            $0.top.equalTo(titleSkeleton.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }

        // Save Button
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(56)
        }
    }

    private func setupActions() {
        saveButton.addTarget(
            self,
            action: #selector(saveButtonTapped),
            for: .touchUpInside
        )
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }

    private func setupActivityItems() {
        guard let result = result else { return }

        result.activityItems.forEach { item in
            let itemView = AIActivityItemView(item: item)
            itemView.onSelected = { [weak self] _ in
                self?.dismissKeyboard()
                self?.handleItemSelection(itemView)
            }

            activityStackView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }
    }
}

// MARK: - Actions

extension AIActivityListView {
    @objc private func dismissKeyboard() {
        itemViews.forEach { $0.dismissKeyboard() }
    }

    private func handleItemSelection(_ itemView: AIActivityItemView) {
        // Deselect all
        itemViews.forEach { $0.setSelected(false) }

        // Select the tapped view
        itemView.setSelected(true)
        selectedItemView = itemView

        // Enable save button
        setSaveButtonEnabled(true)
    }

    @objc private func saveButtonTapped() {
        dismissKeyboard()

        guard let selectedView = selectedItemView else { return }

        let content = selectedView.getContent()

        // Create activity input
        let activityInput = ActivityInput(aiRecommended: true, content: content)

        // Disable button during save
        saveButton.isEnabled = false

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

                    // 토스트 표시 (버튼 위에, 이동하기 액션 포함)
                    ToastView.show(
                        message: "AI 취미활동을 담았어요.",
                        icon: .none,
                        position: .aboveButton(bottomInset: 90),
                        actionTitle: "이동하기",
                        duration: 3.0
                    ) { [weak self] in
                        self?.onNavigateToActivityList?()
                    }

                    // 저장 완료 콜백 (바텀시트 닫지 않음)
                    onActivitySaved?()
                }
            } catch {
                await MainActor.run {
                    setSaveButtonEnabled(true)
                    onError?(error.localizedDescription)
                }
            }
        }
    }

    private func setSaveButtonEnabled(_ isEnabled: Bool) {
        saveButton.isEnabled = isEnabled

        var config = saveButton.configuration
        config?.baseBackgroundColor = isEnabled ? .systemOrange : .systemGray4
        saveButton.configuration = config
    }
}

// MARK: - Skeleton & Data

extension AIActivityListView {
    func showSkeleton() {
        isSkeletonVisible = true

        // Hide actual content
        iconImageView.isHidden = true
        titleLabel.isHidden = true
        activityStackView.isHidden = true

        // Show skeleton views
        iconSkeleton.isHidden = false
        titleSkeleton.isHidden = false
        skeletonStackView.isHidden = false

        // Start animations
        iconSkeleton.startAnimating()
        titleSkeleton.startAnimating()
        activitySkeletons.forEach { $0.startAnimating() }

        // Disable save button during loading
        setSaveButtonEnabled(false)
    }

    func hideSkeleton() {
        isSkeletonVisible = false

        // Stop animations
        iconSkeleton.stopAnimating()
        titleSkeleton.stopAnimating()
        activitySkeletons.forEach { $0.stopAnimating() }

        // Hide skeleton views
        iconSkeleton.isHidden = true
        titleSkeleton.isHidden = true
        skeletonStackView.isHidden = true

        // Show actual content
        iconImageView.isHidden = false
        titleLabel.isHidden = false
        activityStackView.isHidden = false
    }

    func configure(with result: AIActivityItemsResult) {
        self.result = result

        // Clear existing item views
        itemViews.forEach { $0.removeFromSuperview() }
        itemViews.removeAll()
        selectedItemView = nil

        // Configure UI
        titleLabel.setTextWithTypography(result.message, style: .header18)
        setupActivityItems()

        // Hide skeleton
        hideSkeleton()
    }
}
