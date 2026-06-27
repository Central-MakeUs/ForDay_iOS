//
//  ActivityDetailView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ActivityDetailView: UIView {

    // MARK: - Layout Type

    private enum LayoutType {
        case withImage           // 이미지가 있는 경우
        case withoutImage        // 이미지 없고 메모만 있는 경우
        case withoutImageAndMemo // 이미지도 메모도 없는 경우
    }

    // MARK: - Display Mode

    enum DisplayMode {
        case normal           // 일반 상세보기 (반응 버튼 표시)
        case afterRecord      // 기록 완료 후 (홈으로 가기 버튼 표시)
    }

    // MARK: - Constants

    private enum Layout {
        /// 내비게이션 바 높이
        static let navBarHeight: CGFloat = 56
        /// 반응 버튼 바 높이
        static let reactionBarHeight: CGFloat = 72
    }

    // MARK: - Properties

    private var displayMode: DisplayMode = .normal
    private var isPagingMode: Bool = false

    // 커스텀 내비게이션 바 (afterRecord 모드에서만 표시)
    private let customNavigationBar = UIView()
    private let navigationTitleLabel = UILabel()

    // 홈으로 가기 버튼 (기록 완료 후 모드에서만 표시)
    let goHomeButton = UIButton()

    // Public access for PageViewController to control paging
    let scrollView = UIScrollView()
    private let contentView = UIView()

    // User info (profile + nickname)
    let userInfoView = UserInfoView()

    // Hobby name (category badge)
    private let hobbyNameContainerView = UIView()
    let hobbyNameLabel = UILabel()

    // Title at top (activity content)
    let titleLabel = UILabel()

    // Date label
    let dateLabel = UILabel()
    private let privacyBadgeView = UIView()
    private let privacyLabel = UILabel()
    private let privacyChevronImageView = UIImageView()

    // Image carousel (다중 이미지 지원)
    private let imageCarouselView = ImageCarouselView()
    private var currentImages: [ActivityDetailImage] = []
    private var stickerType: StickerType?

    // Memo container (with background)
    private let memoContainerView = UIView()
    let contentLabel = UILabel()
    private let memoStickerImageView = UIImageView() // 이미지 없을 때 메모 안 스티커

    // Reaction Views (단일 보기 모드 전용)
    let reactionButtonsView = ReactionButtonsView()

    private var currentLayoutType: LayoutType = .withImage
    private(set) var hasImage: Bool = false
    private var currentImageAspectRatio: CGFloat?

    // MARK: - Initialization

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

        if hasImage {
            updateImageHeightForCurrentWidth()
        }
    }

    // MARK: - Configuration

    func configure(with detail: ActivityDetail) {
        // Determine layout type
        currentImages = detail.images
        hasImage = !detail.images.isEmpty
        let hasMemo = !detail.memo.isEmpty

        if hasImage {
            currentLayoutType = .withImage
        } else if hasMemo {
            currentLayoutType = .withoutImage
        } else {
            currentLayoutType = .withoutImageAndMemo
        }

        // Configure user info (only show if userInfo exists and not owner's own record)
        if let userInfo = detail.userInfo, !detail.recordOwner {
            userInfoView.isHidden = false
            userInfoView.configure(profileImageUrl: userInfo.profileImageUrl, nickname: userInfo.nickname)
        } else {
            userInfoView.isHidden = true
        }

        // Configure hobby name (category badge)
        let displayHobbyName = detail.hobbyName.isEmpty ? "취미" : detail.hobbyName
        hobbyNameLabel.setTextWithTypography(displayHobbyName, style: .label12)

        // Load sticker image
        if let loadedStickerType = StickerType(fileName: detail.sticker) {
            self.stickerType = loadedStickerType
            imageCarouselView.stickerImage = loadedStickerType.image
            memoStickerImageView.image = loadedStickerType.image
        }

        // Configure title (at top) and date
        titleLabel.setTextWithTypography(detail.activityContent, style: .header20)
        dateLabel.setTextWithTypography(detail.createdAt, style: .label14)
        updatePrivacyBadge(with: detail)

        // Configure memo
        if hasMemo {
            contentLabel.setTextWithTypography(detail.memo, style: .body14)
            contentLabel.textColor = .neutral900
            memoContainerView.isHidden = false
        } else {
            memoContainerView.isHidden = true
        }

        // Configure image carousel
        if hasImage {
            imageCarouselView.configure(with: detail.images)
            updateImageHeight(imageWidth: detail.imageWidth, imageHeight: detail.imageHeight)
            imageCarouselView.isHidden = false
            memoStickerImageView.isHidden = true
        } else {
            resetImageLayout()
            imageCarouselView.isHidden = true
            // 이미지 없을 때는 메모 안(또는 날짜 아래)에 스티커 표시
            memoStickerImageView.isHidden = false
        }

        // 단일 보기 모드인 경우 버튼 구성
        if !isPagingMode {
            reactionButtonsView.configure(with: detail)
        }

        // Update layout based on type
        updateLayoutForType()

        // Update title position based on userInfoView visibility
        updateTitlePosition()
    }

    private func updateTitlePosition() {
        if userInfoView.isHidden {
            // userInfoView가 숨김일 때: hobbyNameContainerView를 최상단에 배치
            hobbyNameContainerView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(16)
                $0.leading.equalToSuperview().offset(20)
            }
        } else {
            // userInfoView가 보일 때: hobbyNameContainerView를 userInfoView 아래에 배치
            hobbyNameContainerView.snp.remakeConstraints {
                $0.top.equalTo(userInfoView.snp.bottom).offset(8)
                $0.leading.equalToSuperview().offset(20)
            }
        }

        // titleLabel은 항상 hobbyNameContainerView 아래에 배치
        titleLabel.snp.remakeConstraints {
            $0.top.equalTo(hobbyNameContainerView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }

    private func updatePrivacyBadge(with detail: ActivityDetail) {
        guard detail.recordOwner else {
            privacyBadgeView.isHidden = true
            return
        }

        privacyBadgeView.isHidden = false
        let privacyTitle = Privacy(rawValue: detail.visibility)?.title ?? {
            switch detail.visibility {
            case "FRIENDS_ONLY":
                return Privacy.friend.title
            default:
                return Privacy.public.title
            }
        }()
        privacyLabel.setTextWithTypography(privacyTitle, style: .label14)
    }

    private func updateImageHeight(imageWidth: Int?, imageHeight: Int?) {
        guard let imageWidth,
              let imageHeight,
              imageWidth > 0,
              imageHeight > 0 else {
            resetImageLayout()
            return
        }

        updateImageHeight(imageWidth: CGFloat(imageWidth), imageHeight: CGFloat(imageHeight))
    }

    private func updateImageHeight(imageWidth: CGFloat, imageHeight: CGFloat) {
        guard imageWidth > 0, imageHeight > 0 else { return }

        currentImageAspectRatio = imageHeight / imageWidth
        updateImageHeightForCurrentWidth()
    }

    private func updateImageHeightForCurrentWidth() {
        guard let currentImageAspectRatio else { return }

        let containerWidth = max(imageCarouselView.bounds.width, bounds.width, window?.bounds.width ?? UIScreen.main.bounds.width)
        let imageWidth = containerWidth - 40 // 좌우 패딩 20씩
        guard imageWidth > 0 else { return }

        let calculatedHeight = imageWidth * currentImageAspectRatio

        imageCarouselView.snp.updateConstraints {
            $0.height.equalTo(calculatedHeight + 24) // 이미지 높이 + 페이지 인디케이터(8) + 간격(16)
        }
    }

    private func resetImageLayout() {
        currentImageAspectRatio = nil
        imageCarouselView.isHidden = true
        imageCarouselView.snp.updateConstraints {
            $0.height.equalTo(0)
        }
    }

    private func updateLayoutForType() {
        // Update constraints based on layout type
        switch currentLayoutType {
        case .withImage:
            // 이미지가 있을 때: 이미지 아래에 날짜
            dateLabel.snp.remakeConstraints {
                $0.top.equalTo(imageCarouselView.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.lessThanOrEqualTo(privacyBadgeView.snp.leading).offset(-8)
            }
            // 메모 텍스트
            contentLabel.snp.remakeConstraints {
                $0.top.leading.equalTo(memoContainerView).offset(16)
                $0.trailing.bottom.equalTo(memoContainerView).offset(-16)
            }
            // 메모 컨테이너 전체 너비
            memoContainerView.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.equalToSuperview().offset(-100) // ReactionButtonsView(72) + 여유 공간 고려
            }

        case .withoutImage:
            // 이미지 없을 때: 타이틀 아래에 날짜
            dateLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(8)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.lessThanOrEqualTo(privacyBadgeView.snp.leading).offset(-8)
            }
            // 메모 텍스트
            contentLabel.snp.remakeConstraints {
                $0.top.leading.equalTo(memoContainerView).offset(16)
                $0.trailing.equalTo(memoContainerView).offset(-16)
            }
            // 스티커
            memoStickerImageView.snp.remakeConstraints {
                $0.top.equalTo(contentLabel.snp.bottom).offset(20)
                $0.trailing.equalToSuperview().offset(-36)
                $0.size.equalTo(80)
            }
            // 메모 컨테이너
            memoContainerView.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.equalTo(memoStickerImageView.snp.bottom).offset(16)
                $0.bottom.equalToSuperview().offset(-100) // ReactionButtonsView(72) + 여유 공간 고려
            }

        case .withoutImageAndMemo:
            dateLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(24)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.lessThanOrEqualTo(privacyBadgeView.snp.leading).offset(-8)
            }
            memoStickerImageView.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(24)
                $0.trailing.equalToSuperview().offset(-20)
                $0.size.equalTo(80)
                $0.bottom.equalToSuperview().offset(-100) // ReactionButtonsView(72) + 여유 공간 고려
            }
        }
    }
}

// MARK: - Setup

extension ActivityDetailView {
    private func style() {
        backgroundColor = .systemBackground

        customNavigationBar.do {
            $0.backgroundColor = .systemBackground
            $0.isHidden = true
        }

        navigationTitleLabel.do {
            $0.setTextWithTypography("내 활동 보기", style: .header18)
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }

        goHomeButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "홈으로 가기"
            config.baseBackgroundColor = .action001
            config.baseForegroundColor = .neutralWhite
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 0, bottom: 19, trailing: 0)
            $0.configuration = config
            $0.isHidden = true
        }

        scrollView.do {
            $0.showsVerticalScrollIndicator = true
            $0.alwaysBounceVertical = true // 콘텐츠가 짧아도 바운스되어야 페이징 감지 가능
        }

        contentView.do {
            $0.backgroundColor = .systemBackground
        }

        userInfoView.do {
            $0.isHidden = true
        }

        hobbyNameContainerView.do {
            $0.backgroundColor = .primary003
            $0.layer.cornerRadius = 8
        }

        hobbyNameLabel.do {
            $0.textColor = .action001
            $0.textAlignment = .center
        }

        titleLabel.do {
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        dateLabel.do {
            $0.textColor = .neutral600
        }

        privacyBadgeView.do {
            $0.backgroundColor = .clear
            $0.isHidden = true
        }

        privacyLabel.do {
            $0.textColor = .neutral600
            $0.textAlignment = .right
        }

        privacyChevronImageView.do {
            $0.image = .Icon.chevronDown
            $0.tintColor = .neutral600
            $0.contentMode = .scaleAspectFit
        }

        memoStickerImageView.do {
            $0.contentMode = .scaleAspectFit
        }

        memoContainerView.do {
            $0.backgroundColor = .bg002
            $0.layer.cornerRadius = 12
        }

        contentLabel.do {
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }
    }

    private func layout() {
        addSubview(customNavigationBar)
        addSubview(goHomeButton)
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        addSubview(reactionButtonsView)

        customNavigationBar.addSubview(navigationTitleLabel)

        // 커스텀 내비게이션 바 레이아웃
        customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.navBarHeight)
        }

        navigationTitleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }

        updateScrollViewConstraints()

        reactionButtonsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(Layout.reactionBarHeight)
        }

        goHomeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            // height는 내부 서브뷰들에 의해 자동 결정됨
        }

        contentView.addSubview(userInfoView)
        contentView.addSubview(hobbyNameContainerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageCarouselView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(privacyBadgeView)
        contentView.addSubview(memoContainerView)
        contentView.addSubview(memoStickerImageView)

        hobbyNameContainerView.addSubview(hobbyNameLabel)
        privacyBadgeView.addSubview(privacyLabel)
        privacyBadgeView.addSubview(privacyChevronImageView)

        userInfoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
            $0.height.equalTo(24)
        }

        hobbyNameContainerView.snp.makeConstraints {
            $0.top.equalTo(userInfoView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }

        hobbyNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalToSuperview().offset(6)
            $0.trailing.equalToSuperview().offset(-6)
            $0.bottom.equalToSuperview().offset(-4)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(hobbyNameContainerView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        imageCarouselView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(324) // 기본 높이 (300 + 페이지 인디케이터 24)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(imageCarouselView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualTo(privacyBadgeView.snp.leading).offset(-8)
        }

        privacyBadgeView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(dateLabel)
        }

        privacyLabel.snp.makeConstraints {
            $0.leading.verticalEdges.equalToSuperview()
        }

        privacyChevronImageView.snp.makeConstraints {
            $0.leading.equalTo(privacyLabel.snp.trailing).offset(4)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(privacyLabel)
            $0.size.equalTo(16)
        }

        memoContainerView.addSubview(contentLabel)
        memoContainerView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            // bottom은 updateLayoutForType에서 pinned됨
        }

        contentLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        memoStickerImageView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(80)
        }
    }

    private func updateScrollViewConstraints() {
        scrollView.snp.remakeConstraints {
            if displayMode == .afterRecord {
                $0.top.equalTo(customNavigationBar.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(goHomeButton.snp.top).offset(-16)
            } else {
                $0.top.equalTo(safeAreaLayoutGuide).offset(Layout.navBarHeight)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(safeAreaLayoutGuide).offset(-Layout.reactionBarHeight)
            }
        }
    }
}

// MARK: - Public Methods

extension ActivityDetailView {
    func setRefreshControl(_ refreshControl: UIRefreshControl) {
        scrollView.refreshControl = refreshControl
    }

    func endRefreshing() {
        scrollView.refreshControl?.endRefreshing()
    }

    func setDisplayMode(_ mode: DisplayMode) {
        displayMode = mode

        if mode == .afterRecord {
            customNavigationBar.isHidden = false
            reactionButtonsView.isHidden = true
            goHomeButton.isHidden = false
        } else {
            customNavigationBar.isHidden = true
            reactionButtonsView.isHidden = false
            goHomeButton.isHidden = true
        }

        updateScrollViewConstraints()
    }

    func setPagingMode(_ enabled: Bool) {
        isPagingMode = enabled

        // afterRecord 모드일 때는 항상 반응 버튼 숨김
        if displayMode == .afterRecord {
            reactionButtonsView.isHidden = true
        } else {
            reactionButtonsView.isHidden = enabled
        }

        updateScrollViewConstraints()
    }

    /// 첫 번째 이미지 URL 반환 (공유용)
    var firstImageUrl: String? {
        return currentImages.first?.imageUrl
    }

    /// 모든 이미지 반환
    var allImages: [ActivityDetailImage] {
        return currentImages
    }
}
