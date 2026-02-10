//
//  HomeView.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import UIKit
import SnapKit
import Then
//import Lott

class HomeView: UIView {

    // Properties

    private let backgroundImageView = UIImageView()

    let scrollView = UIScrollView()
    let refreshControl = UIRefreshControl()
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    let firstHobbyButton = UIButton()
    private let dividerImage = UIImageView()
//    private let dividerLabel = UILabel()
    let secondHobbyButton = UIButton()
    let addHobbyButton = UIButton() // For no-hobby state
    let settingsButton = UIButton()
    let notificationButton = UIButton()
    
    // AI Recommendation Toast
    let toastView = AIRecommendationToastView()

    // My Activity Section
    private let myActivitySectionView = UIView()
    private let myActivityTitleLabel = UILabel()
    let myActivityChevronButton = UIButton()
    
    // Activity Card
    let activityCardView = UIView()
    let emptyActivityLabel = UILabel()
    let activityDropdownButton = UIButton()
    let addActivityButton = UIButton()
    
    // Sticker Collection Section
    let stickerBoardView = StickerBoardView()

    // Floating Action Button
    let dimOverlayView = UIView()
    let floatingActionButton = FloatingActionButton()
    let floatingActionMenu = FloatingActionMenu()


    // Gradient Layer for addActivityButton
    private var addActivityButtonGradientLayer: CAGradientLayer?

    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 그라데이션 레이어 프레임 업데이트
        addActivityButtonGradientLayer?.frame = addActivityButton.bounds
    }
}

// Setup

extension HomeView {
    private func style() {
        backgroundColor = .systemBackground
        
        backgroundImageView.do {
            $0.image = .App.background
            $0.contentMode = .scaleAspectFill
        }
        
        scrollView.do {
            $0.showsVerticalScrollIndicator = false
            $0.refreshControl = refreshControl
            $0.alwaysBounceVertical = true
        }
        
        // Header
        headerView.do {
            $0.backgroundColor = .clear
        }

        firstHobbyButton.do {
            var config = UIButton.Configuration.plain()
            config.baseForegroundColor = .neutral900
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            config.background.cornerRadius = 0
            config.background.backgroundColor = .clear
            $0.configuration = config
            $0.configurationUpdateHandler = { button in
                var config = button.configuration
                config?.baseForegroundColor = button.isHighlighted ? .neutral900 : .neutral900
                button.configuration = config
            }
        }
        
        dividerImage.do {
            $0.image = .Icon.divider
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }

        secondHobbyButton.do {
            var config = UIButton.Configuration.plain()
            config.baseForegroundColor = .neutral500
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            config.background.cornerRadius = 0
            config.background.backgroundColor = .clear
            $0.configuration = config
            $0.configurationUpdateHandler = { button in
                var config = button.configuration
                config?.baseForegroundColor = button.isHighlighted ? .neutral500 : .neutral500
                button.configuration = config
            }
            $0.isHidden = true // 기본적으로 숨김 (취미가 2개일 때만 표시)
        }

        addHobbyButton.do {
            var config = UIButton.Configuration.plain()
            config.baseForegroundColor = .neutral900
            config.image = .Icon.chevronRight
            config.imagePlacement = .trailing
            config.imagePadding = 4
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            config.background.cornerRadius = 0
            config.background.backgroundColor = .clear
            $0.configuration = config
            $0.setTitleWithTypography("취미 추가", style: .header22)
            $0.isHidden = true // 기본적으로 숨김 (취미가 없을 때만 표시)
        }

        settingsButton.do {
            $0.setImage(.Icon.settings, for: .normal)
            $0.tintColor = .neutral500
        }

        notificationButton.do {
            $0.setImage(.Icon.notificationOff, for: .normal)
            $0.tintColor = .neutral500
            $0.isHidden = true // TODO: 알림 기능 연결 시 활성화
        }
        
        // AI Recommendation Toast
        toastView.do {
            $0.isHidden = true // 초기에는 숨김, homeInfo 로드 후 표시
        }

        // My Activity Section
        myActivityTitleLabel.do {
            $0.setTextWithTypography("나의 취미활동", style: .header16)
            $0.textColor = .neutral900
        }
        
        myActivityChevronButton.do {
            $0.setImage(.Icon.chevronRight, for: .normal)
            $0.tintColor = .neutral500
        }
        
        // Activity Card - Empty State
        activityCardView.do {
            $0.backgroundColor = .bg001
            $0.layer.cornerRadius = 16
            
            // TODO: shadow custom
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.05
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 4
        }
        
        emptyActivityLabel.do {
            $0.setTextWithTypography("등록된 취미활동이 없어요.", style: .body14)
            $0.textColor = .neutral600
            $0.textAlignment = .center
            $0.isHidden = true // 기본적으로 숨김
        }

        activityDropdownButton.do {
            var config = UIButton.Configuration.plain()
            config.image = .Icon.chevronDown
            config.imagePlacement = .trailing
            config.imagePadding = 8
            config.baseForegroundColor = .label
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .systemFont(ofSize: 16, weight: .medium)
                return outgoing
            }
            $0.configuration = config
            $0.contentHorizontalAlignment = .leading
            $0.isHidden = true // 기본적으로 숨김
        }

        addActivityButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .primary003
            config.baseForegroundColor = .action001
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)

            $0.configuration = config
            $0.setTitleWithTypography("취미활동 추가하기", style: .header14)
        }
        
        // Sticker Section - 바텀시트 스타일 (상단만 라운드)
        stickerBoardView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 20
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단만 라운드

            // 그림자 설정
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.08
            $0.layer.shadowOffset = CGSize(width: 0, height: -2)
            $0.layer.shadowRadius = 8
        }

        // Floating Action Button
        dimOverlayView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            $0.alpha = 0
            $0.isHidden = true
        }

    }
    
    private func layout() {
        // 배경 이미지: self에 직접 추가하여 status bar 영역까지 커버
        insertSubview(backgroundImageView, at: 0)

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerView)
        contentView.addSubview(toastView)
        contentView.addSubview(myActivitySectionView)
        contentView.addSubview(activityCardView)
        contentView.addSubview(stickerBoardView)

        // Floating elements (added to self, not contentView, to stay above all content)
        addSubview(dimOverlayView)
        addSubview(floatingActionMenu)
        addSubview(floatingActionButton)

        
        // Header
        headerView.addSubview(firstHobbyButton)
        headerView.addSubview(dividerImage)
        headerView.addSubview(secondHobbyButton)
        headerView.addSubview(addHobbyButton)
        headerView.addSubview(settingsButton)
        headerView.addSubview(notificationButton)
        
        // My Activity Section
        myActivitySectionView.addSubview(myActivityTitleLabel)
        myActivitySectionView.addSubview(myActivityChevronButton)
        
        // Activity Card
        activityCardView.addSubview(emptyActivityLabel)
        activityCardView.addSubview(activityDropdownButton)
        activityCardView.addSubview(addActivityButton)
        
        // Sticker Section - StickerBoardView 자체가 완성된 컴포넌트
        
        backgroundImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            // safe area 포함 세로 길이 - 66*2
            $0.width.height.equalTo(UIScreen.main.bounds.height)
        }

        contentView.clipsToBounds = true

        // ScrollView
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }

        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(scrollView) // 최소 화면 높이 보장
        }
        
        // Header
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        firstHobbyButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-12)
        }

        dividerImage.snp.makeConstraints {
            $0.leading.equalTo(firstHobbyButton.snp.trailing).offset(10)
            $0.centerY.equalTo(firstHobbyButton)
        }

        secondHobbyButton.snp.makeConstraints {
            $0.leading.equalTo(dividerImage.snp.trailing).offset(10)
            $0.centerY.equalTo(firstHobbyButton)
        }

        addHobbyButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-12)
        }

        settingsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(firstHobbyButton)
            $0.width.height.equalTo(24)
        }

        // TODO: 알림 기능 연결 시 활성화 후 settingsButton을 notificationButton 왼쪽으로 이동
        notificationButton.snp.makeConstraints {
            $0.trailing.equalTo(settingsButton.snp.leading).offset(-12)
            $0.centerY.equalTo(firstHobbyButton)
            $0.width.height.equalTo(24)
        }
        
        // AI Recommendation Toast
        toastView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // My Activity Section
        myActivitySectionView.snp.makeConstraints {
            $0.top.equalTo(toastView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(24)
        }
        
        myActivityTitleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }

        myActivityChevronButton.snp.makeConstraints {
            $0.leading.equalTo(myActivityTitleLabel.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        
        // Activity Card
        activityCardView.snp.makeConstraints {
            $0.top.equalTo(myActivitySectionView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        emptyActivityLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
        }

        activityDropdownButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }

        addActivityButton.snp.makeConstraints {
            $0.top.equalTo(emptyActivityLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-24)
        }
        
        // Sticker Section - 양옆 간격 없이 전체 너비, 하단까지 확장
        stickerBoardView.snp.makeConstraints {
            $0.top.equalTo(activityCardView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview() // 양옆 간격 제거
            $0.height.greaterThanOrEqualTo(320) // 최소 높이: 헤더(44) + 갭(8) + 그리드(~240) + 패딩(28)
            $0.bottom.equalToSuperview() // 하단까지 확장 (탭바 아래까지)
        }

        // Dim Overlay
        dimOverlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Floating Action Button
        floatingActionButton.snp.makeConstraints {
            $0.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }

        // Floating Action Menu
        floatingActionMenu.snp.makeConstraints {
            $0.trailing.equalTo(floatingActionButton)
            $0.bottom.equalTo(floatingActionButton.snp.top).offset(-16)
        }

    }
}

// Public Methods

extension HomeView {
    func updateHobbies(_ hobbies: [InProgressHobby]) {
        if hobbies.isEmpty {
            // 취미가 없는 경우 - "취미 추가" 버튼 표시
            firstHobbyButton.isHidden = true
            dividerImage.isHidden = true
            secondHobbyButton.isHidden = true
            addHobbyButton.isHidden = false

            setNeedsLayout()
            layoutIfNeeded()
        } else if hobbies.count == 1 {
            // 취미가 1개인 경우
            let hobby = hobbies[0]
            firstHobbyButton.setTitleWithTypography(hobby.hobbyName, style: .header22)

            var config = firstHobbyButton.configuration
            config?.baseForegroundColor = .neutral900
            firstHobbyButton.configuration = config

            firstHobbyButton.configurationUpdateHandler = { button in
                var config = button.configuration
                config?.baseForegroundColor = .neutral900
                button.configuration = config
            }

            firstHobbyButton.isHidden = false
            dividerImage.isHidden = true
            secondHobbyButton.isHidden = true
            addHobbyButton.isHidden = true

            // 레이아웃 업데이트
            setNeedsLayout()
            layoutIfNeeded()
        } else if hobbies.count >= 2 {
            // 취미가 2개 이상인 경우 (최대 2개만 표시)
            let firstHobby = hobbies[0]
            let secondHobby = hobbies[1]

            firstHobbyButton.setTitleWithTypography(firstHobby.hobbyName, style: .header22)
            secondHobbyButton.setTitleWithTypography(secondHobby.hobbyName, style: .header22)

            // currentHobby가 true인 취미를 선택 상태로 설정
            if firstHobby.currentHobby {
                var firstConfig = firstHobbyButton.configuration
                firstConfig?.baseForegroundColor = .neutral900
                firstHobbyButton.configuration = firstConfig

                firstHobbyButton.configurationUpdateHandler = { button in
                    var config = button.configuration
                    config?.baseForegroundColor = .neutral900
                    button.configuration = config
                }

                var secondConfig = secondHobbyButton.configuration
                secondConfig?.baseForegroundColor = .neutral500
                secondHobbyButton.configuration = secondConfig

                secondHobbyButton.configurationUpdateHandler = { button in
                    var config = button.configuration
                    config?.baseForegroundColor = .neutral500
                    button.configuration = config
                }
            } else {
                var firstConfig = firstHobbyButton.configuration
                firstConfig?.baseForegroundColor = .neutral500
                firstHobbyButton.configuration = firstConfig

                firstHobbyButton.configurationUpdateHandler = { button in
                    var config = button.configuration
                    config?.baseForegroundColor = .neutral500
                    button.configuration = config
                }

                var secondConfig = secondHobbyButton.configuration
                secondConfig?.baseForegroundColor = .neutral900
                secondHobbyButton.configuration = secondConfig

                secondHobbyButton.configurationUpdateHandler = { button in
                    var config = button.configuration
                    config?.baseForegroundColor = .neutral900
                    button.configuration = config
                }
            }

            firstHobbyButton.isHidden = false
            dividerImage.isHidden = false
            secondHobbyButton.isHidden = false
            addHobbyButton.isHidden = true

            // 레이아웃 업데이트
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    func updateAddActivityButtonTitle(hasHobbies: Bool) {
        if hasHobbies {
            addActivityButton.setTitleWithTypography("취미활동 추가하기", style: .header14)
        } else {
            addActivityButton.setTitleWithTypography("취미 추가하기", style: .header14)
        }
    }

    func updateActivityPreview(_ activityPreview: ActivityPreview?) {
        if let preview = activityPreview {
            // 활동이 있는 경우
            emptyActivityLabel.isHidden = true
            activityDropdownButton.isHidden = false

            // 드롭다운 버튼 텍스트 설정
            var config = activityDropdownButton.configuration
            config?.title = preview.content
            activityDropdownButton.configuration = config

            // 버튼 텍스트 변경 및 그라데이션 적용
            addActivityButton.setTitleWithTypography("오늘의 스티커 붙이기", style: .header14)
            applyGradientToAddActivityButton()

            // addActivityButton 제약 조건 업데이트 (activityDropdownButton 기준)
            addActivityButton.snp.remakeConstraints {
                $0.top.equalTo(activityDropdownButton.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.equalToSuperview().offset(-24)
            }
        } else {
            // 활동이 없는 경우
            emptyActivityLabel.isHidden = false
            activityDropdownButton.isHidden = true

            // 버튼 텍스트 복원 및 그라데이션 제거
            addActivityButton.setTitleWithTypography("취미활동 추가하기", style: .header14)
            removeGradientFromAddActivityButton()

            // addActivityButton 제약 조건 복원 (emptyActivityLabel 기준)
            addActivityButton.snp.remakeConstraints {
                $0.top.equalTo(emptyActivityLabel.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.equalToSuperview().offset(-24)
            }
        }
    }

    private func applyGradientToAddActivityButton() {
        // 기존 그라데이션 제거
        addActivityButtonGradientLayer?.removeFromSuperlayer()

        // 버튼 배경색 투명으로 변경
        var config = addActivityButton.configuration
        config?.baseBackgroundColor = .clear
        config?.baseForegroundColor = .neutralWhite
        addActivityButton.configuration = config

        // 그라데이션 레이어 생성 (gradient002: F4A261 → F77F78)
        let gradientLayer = DesignGradient.gradient002.makeLayer()
        gradientLayer.cornerRadius = 12

        // 레이아웃 후 프레임 설정을 위해 지연 실행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            gradientLayer.frame = self.addActivityButton.bounds
            self.addActivityButton.layer.insertSublayer(gradientLayer, at: 0)
            self.addActivityButtonGradientLayer = gradientLayer
        }
    }

    private func removeGradientFromAddActivityButton() {
        // 그라데이션 레이어 제거
        addActivityButtonGradientLayer?.removeFromSuperlayer()
        addActivityButtonGradientLayer = nil

        // 버튼 배경색 복원
        var config = addActivityButton.configuration
        config?.baseBackgroundColor = .primary003
        config?.baseForegroundColor = .action001
        addActivityButton.configuration = config
    }

    func showFloatingMenu() {
        dimOverlayView.isHidden = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.dimOverlayView.alpha = 1
        }

        floatingActionButton.isExpanded = true
        floatingActionMenu.show(animated: true)
    }

    func hideFloatingMenu() {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.dimOverlayView.alpha = 0
            },
            completion: { [weak self] _ in
                self?.dimOverlayView.isHidden = true
            }
        )

        floatingActionButton.isExpanded = false
        floatingActionMenu.hide(animated: true)
    }

    // MARK: - AI Toast

    func configureToast(with greetingMessage: String, aiCallRemaining: Bool) {
        toastView.configure(with: greetingMessage)
        toastView.isHidden = false
    }

    func expandToast(animated: Bool = true) {
        toastView.expand(animated: animated)
    }

    func collapseToast(animated: Bool = true) {
        toastView.collapse(animated: animated)
    }
}

#Preview {
    HomeView()
}
