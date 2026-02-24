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

    // Navigation Bar
    private let navigationBar = UIView()
    private let backButton = UIButton()
    private let navigationTitleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let iconImageView = UIImageView()

    // Title Area
    private let titleContainerView = UIView()
    private let titleFirstLineStackView = UIStackView()
    private let titleFirstLineLabel = UILabel()
    private let titleSecondLineStackView = UIStackView()
    private let titleSecondLineLabel = UILabel()
    private let infoButton = UIButton()

    // Tooltip
    private let tooltipContainerView = UIView()
    private let tooltipBubbleView = UIView()
    private let tooltipLabel = UILabel()
    private let tooltipPolygonImageView = UIImageView()

    private let activityStackView = UIStackView()

    // Bottom Buttons
    private let bottomContainerView = UIView()
    private let refreshButton = UIButton()
    private let refreshIconImageView = UIImageView()
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

    /// 내비게이션 표시 여부 (fullscreen 모드에서만 true)
    private var showNavigation: Bool = true

    // Callbacks
    /// 저장 모드: hobbyId가 있을 때 CreateActivitiesUseCase로 저장 후 호출
    var onActivitySaved: (() -> Void)?
    /// 선택 모드: 선택된 활동 content를 반환 (저장하지 않음)
    var onActivitySelected: ((String) -> Void)?
    var onRefreshTapped: (() -> Void)?
    var onBackTapped: (() -> Void)?
    var onError: ((String) -> Void)?
    /// 활동 저장 후 ActivityList로 이동
    var onNavigateToActivityList: (() -> Void)?

    // MARK: - Initialization

    /// 저장 모드: hobbyId를 전달하면 다음 버튼 클릭 시 바로 저장
    init(
        result: AIRecommendationResult,
        hobbyId: Int,
        showNavigation: Bool = true,
        createActivitiesUseCase: CreateActivitiesUseCase = CreateActivitiesUseCase()
    ) {
        self.result = result
        self.hobbyId = hobbyId
        self.showNavigation = showNavigation
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
    init(result: AIRecommendationResult, showNavigation: Bool = true) {
        self.result = result
        self.hobbyId = nil
        self.showNavigation = showNavigation
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

// MARK: - Setup

extension AIActivitySelectionView {
    private func configure() {
        // recommendedText를 문장 단위로 분리 (마침표 기준)
        let sentences = splitIntoSentences(result.recommendedText)

        // infoButton을 기존 위치에서 제거
        infoButton.removeFromSuperview()

        if sentences.count >= 2 {
            titleFirstLineLabel.setTextWithTypography(sentences[0], style: .header18)
            titleFirstLineLabel.textAlignment = .center
            titleSecondLineLabel.setTextWithTypography(sentences[1], style: .header18)
            titleSecondLineLabel.textAlignment = .center
            titleSecondLineStackView.isHidden = false
            // 2줄인 경우 두 번째 줄 옆에 info 버튼 배치
            titleSecondLineStackView.addArrangedSubview(infoButton)
        } else {
            // 1문장인 경우 첫 번째 줄만 표시
            titleFirstLineLabel.setTextWithTypography(result.recommendedText, style: .header18)
            titleFirstLineLabel.textAlignment = .center
            titleSecondLineStackView.isHidden = true
            // 1줄인 경우 첫 번째 줄 옆에 info 버튼 배치
            titleFirstLineStackView.addArrangedSubview(infoButton)
        }

        // infoButton 크기 제약 재설정 (24x24로 터치 영역 확보)
        infoButton.snp.remakeConstraints {
            $0.size.equalTo(24)
        }
    }

    /// 텍스트를 문장 단위로 분리
    private func splitIntoSentences(_ text: String) -> [String] {
        // 마침표, 느낌표, 물음표로 문장 구분
        var sentences: [String] = []
        var currentSentence = ""

        for char in text {
            currentSentence.append(char)
            if char == "." || char == "!" || char == "?" {
                sentences.append(currentSentence.trimmingCharacters(in: .whitespaces))
                currentSentence = ""
            }
        }

        // 남은 텍스트가 있으면 추가
        if !currentSentence.trimmingCharacters(in: .whitespaces).isEmpty {
            sentences.append(currentSentence.trimmingCharacters(in: .whitespaces))
        }

        return sentences
    }

    private func style() {
        backgroundColor = .neutralWhite

        // Navigation Bar
        navigationBar.do {
            $0.backgroundColor = .neutralWhite
        }

        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral800
        }

        navigationTitleLabel.do {
            $0.setTextWithTypography("AI 추천 활동", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

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

        // Title First Line Stack
        titleFirstLineStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }

        // Title First Line
        titleFirstLineLabel.do {
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }

        // Title Second Line Stack
        titleSecondLineStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }

        // Title Second Line Label
        titleSecondLineLabel.do {
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }

        // Info Button (터치 영역 24x24, 이미지 16x16 중앙 배치)
        infoButton.do {
            var config = UIButton.Configuration.plain()
            config.image = .Icon.info.resized(to: CGSize(width: 16, height: 16))
            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            $0.configuration = config
        }

        // Tooltip Container (터치 감지용)
        tooltipContainerView.do {
            $0.backgroundColor = .clear
            $0.isHidden = true
        }

        // Tooltip Bubble
        tooltipBubbleView.do {
            $0.backgroundColor = .neutral900
            $0.layer.cornerRadius = 21
        }

        // Tooltip Label
        tooltipLabel.do {
            $0.setTextWithTypography(
                "사용자의 취미취향과 다른 유저의\n데이터 기반 추천을 기반하여\n선별된 포데이 AI 추천 취미활동입니다.",
                style: .label12
            )
            $0.textColor = .neutralWhite
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }

        // Tooltip Polygon (삼각형)
        tooltipPolygonImageView.do {
            $0.image = .Polygon.infoPolygon
            $0.contentMode = .scaleAspectFit
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
            $0.spacing = 10
            $0.distribution = .fill
            $0.isHidden = true
        }

        // Setup skeleton items
        setupSkeletonItems()

        // Refresh Button - 정사각형 안에 아이콘 + 횟수
        refreshButton.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke002.cgColor
        }

        refreshIconImageView.do {
            $0.image = .Icon.reload
            $0.tintColor = .neutral800
            $0.contentMode = .scaleAspectFit
        }

        refreshCountLabel.do {
            $0.textColor = .neutral400
            $0.textAlignment = .center
        }

        // Next Button
        nextButton.do {
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
        // Create 3 skeleton items
        for _ in 0..<3 {
            let skeleton = ActivityItemSkeletonView()
            activitySkeletons.append(skeleton)
            skeletonStackView.addArrangedSubview(skeleton)
        }
    }

    private func layout() {
        // Navigation Bar (showNavigation이 true일 때만 표시)
        if showNavigation {
            addSubview(navigationBar)
            navigationBar.addSubview(backButton)
            navigationBar.addSubview(navigationTitleLabel)
        }

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(iconImageView)
        contentView.addSubview(titleContainerView)
        titleContainerView.addSubview(titleFirstLineStackView)
        titleFirstLineStackView.addArrangedSubview(titleFirstLineLabel)
        titleContainerView.addSubview(titleSecondLineStackView)
        titleSecondLineStackView.addArrangedSubview(titleSecondLineLabel)
        // infoButton은 configure()에서 문장 개수에 따라 동적으로 추가
        contentView.addSubview(activityStackView)

        // Tooltip (contentView 위에 표시)
        addSubview(tooltipContainerView)
        tooltipContainerView.addSubview(tooltipBubbleView)
        tooltipBubbleView.addSubview(tooltipLabel)
        tooltipContainerView.addSubview(tooltipPolygonImageView)

        // Skeleton views
        contentView.addSubview(iconSkeleton)
        contentView.addSubview(titleSkeleton1)
        contentView.addSubview(titleSkeleton2)
        contentView.addSubview(skeletonStackView)

        // Bottom buttons
        addSubview(refreshButton)
        refreshButton.addSubview(refreshIconImageView)
        refreshButton.addSubview(refreshCountLabel)
        addSubview(nextButton)

        // Navigation Bar (showNavigation이 true일 때만 레이아웃)
        if showNavigation {
            navigationBar.snp.makeConstraints {
                $0.top.equalTo(safeAreaLayoutGuide)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(44)
            }

            backButton.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(20)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(24)
            }

            navigationTitleLabel.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }

        // ScrollView - showNavigation에 따라 상단 위치 결정
        scrollView.snp.makeConstraints {
            if showNavigation {
                $0.top.equalTo(navigationBar.snp.bottom)
            } else {
                $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            }
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(refreshButton.snp.top).offset(-16)
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

        // Title Container
        titleContainerView.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }

        // Title First Line Stack
        titleFirstLineStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }

        // Title Second Line Stack
        titleSecondLineStackView.snp.makeConstraints {
            $0.top.equalTo(titleFirstLineStackView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.bottom.equalToSuperview()
        }

        // Tooltip Container (전체 화면을 덮음)
        tooltipContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Tooltip Label (버블 내부 여백)
        tooltipLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        // 초기 위치는 화면 밖에 설정 (실제 위치는 infoButtonTapped에서 계산)
        tooltipBubbleView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(snp.top)
        }

        tooltipPolygonImageView.snp.makeConstraints {
            $0.top.equalTo(tooltipBubbleView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(10)
            $0.height.equalTo(4)
        }

        // Activity Stack
        activityStackView.snp.makeConstraints {
            $0.top.equalTo(titleContainerView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }

        // Icon Skeleton
        iconSkeleton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(42)
        }

        // Title Skeletons
        titleSkeleton1.snp.makeConstraints {
            $0.top.equalTo(iconSkeleton.snp.bottom).offset(10)
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
            $0.top.equalTo(titleSkeleton2.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }

        // Refresh Button - 정사각형
        refreshButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.size.equalTo(56)
        }

        // Refresh Icon - 버튼 내부 상단
        refreshIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(20)
        }

        // Refresh Count - 버튼 내부 아이콘 아래
        refreshCountLabel.snp.makeConstraints {
            $0.top.equalTo(refreshIconImageView.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
        }

        // Next Button
        nextButton.snp.makeConstraints {
            $0.leading.equalTo(refreshButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(refreshButton)
            $0.height.equalTo(56)
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
        backButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )

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

        infoButton.addTarget(
            self,
            action: #selector(infoButtonTapped),
            for: .touchUpInside
        )

        // Tooltip dismiss (터치 시 숨김)
        let tooltipTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideTooltip)
        )
        tooltipContainerView.addGestureRecognizer(tooltipTapGesture)
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

    @objc private func backButtonTapped() {
        onBackTapped?()
    }

    @objc private func infoButtonTapped() {
        // infoButton의 위치를 self 좌표계로 변환
        let infoButtonFrame = infoButton.convert(infoButton.bounds, to: self)

        // 삼각형: info 버튼 바로 위
        tooltipPolygonImageView.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(bounds.height - infoButtonFrame.minY + 1)
            $0.centerX.equalToSuperview().offset(infoButtonFrame.midX - bounds.width / 2)
            $0.width.equalTo(10)
            $0.height.equalTo(4)
        }

        // 말풍선: 삼각형 바로 위에 붙음, 오른쪽에서 40pt
        tooltipBubbleView.snp.remakeConstraints {
            $0.bottom.equalTo(tooltipPolygonImageView.snp.top)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // 라벨: 좌우 12, 상하 8 패딩
        tooltipLabel.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        tooltipContainerView.isHidden = false
        layoutIfNeeded()
    }

    @objc private func hideTooltip() {
        tooltipContainerView.isHidden = true
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
        Task { [weak self] in
            guard let self = self else { return }
            do {
                _ = try await createActivitiesUseCase.execute(
                    hobbyId: hobbyId,
                    activities: [activityInput]
                )

                await MainActor.run { [weak self] in
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
                    self?.onActivitySaved?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.setNextButtonEnabled(true)
                    self?.onError?(error.localizedDescription)
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
        titleContainerView.isHidden = true
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
        titleContainerView.isHidden = false
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
