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

    // Image container (with padding)
    private let imageContainerView = UIView()
    let imageView = UIImageView()
    let stickerImageView = UIImageView()

    // Memo container (with background)
    private let memoContainerView = UIView()
    let contentLabel = UILabel()
    private let memoStickerImageView = UIImageView() // 이미지 없을 때 메모 안 스티커

    // Reaction Views (단일 보기 모드 전용)
    let reactionUsersScrollView = ReactionUsersScrollView()
    let reactionButtonsView = ReactionButtonsView()

    private var currentLayoutType: LayoutType = .withImage
    private(set) var hasImage: Bool = false

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with detail: ActivityDetail) {
        // Determine layout type
        hasImage = !detail.imageUrl.isEmpty
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
        if let stickerType = StickerType(fileName: detail.sticker) {
            stickerImageView.image = stickerType.image
            memoStickerImageView.image = stickerType.image
        }

        // Configure title (at top) and date
        titleLabel.setTextWithTypography(detail.activityContent, style: .header20)
        dateLabel.setTextWithTypography(detail.createdAt, style: .label14)

        // Configure memo
        if hasMemo {
            contentLabel.setTextWithTypography(detail.memo, style: .body14)
            contentLabel.textColor = .neutral900
            memoContainerView.isHidden = false
        } else {
            memoContainerView.isHidden = true
        }

        // Configure image
        if hasImage {
            loadImage(from: detail.imageUrl)
            imageContainerView.isHidden = false
            stickerImageView.isHidden = false
            memoStickerImageView.isHidden = true
        } else {
            imageContainerView.isHidden = true
            stickerImageView.isHidden = true
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

    private func loadImage(from urlString: String) {
        imageView.setImage(with: urlString) { [weak self] result in
            if case .success(let imageResult) = result {
                // 이미지 로드 후 원본 비율로 높이 조정
                self?.updateImageHeight(for: imageResult.image)
            }
        }
    }

    private func updateImageHeight(for image: UIImage) {
        let imageWidth = bounds.width - 40 // 좌우 패딩 20씩
        guard imageWidth > 0 else { return }

        let aspectRatio = image.size.height / image.size.width
        let imageHeight = imageWidth * aspectRatio

        imageView.snp.updateConstraints {
            $0.height.equalTo(imageHeight)
        }

        layoutIfNeeded()
    }

    private func updateLayoutForType() {
        // Update constraints based on layout type
        switch currentLayoutType {
        case .withImage:
            // 이미지가 있을 때: 이미지 아래에 날짜
            dateLabel.snp.remakeConstraints {
                $0.top.equalTo(imageContainerView.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
            }
            // 메모 컨테이너 전체 너비 (스티커가 이미지 위에 있으므로)
            memoContainerView.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.equalToSuperview().offset(-20) // 하단 여백 통일
            }

        case .withoutImage:
            // 이미지 없을 때: 타이틀 아래에 날짜
            dateLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(8)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
            }
            // 메모 텍스트
            contentLabel.snp.remakeConstraints {
                $0.top.leading.equalTo(memoContainerView).offset(16)
                $0.trailing.equalTo(memoContainerView).offset(-16)
            }
            // 스티커를 contentView 기준으로 배치 (시각적으로 메모 컨테이너 안에 있는 것처럼)
            memoStickerImageView.snp.remakeConstraints {
                $0.top.equalTo(contentLabel.snp.bottom).offset(20)
                $0.trailing.equalToSuperview().offset(-36) // 20(컨테이너) + 16(내부 패딩)
                $0.size.equalTo(80)
            }
            // 메모 컨테이너 (스티커 아래까지 확장하고, contentView의 bottom과 연결)
            memoContainerView.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.equalTo(memoStickerImageView.snp.bottom).offset(16)
            }
            // contentView의 bottom을 메모 컨테이너에 연결
            memoContainerView.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(-20)
            }

        case .withoutImageAndMemo:
            // 이미지도 메모도 없을 때: 타이틀 아래 24px → 날짜, 날짜 아래 24px → 스티커 (contentView 기준)
            dateLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(24)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
            }
            memoStickerImageView.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(24)
                $0.trailing.equalToSuperview().offset(-20)
                $0.size.equalTo(80)
                $0.bottom.equalToSuperview().offset(-20)
            }
        }
    }
}

// MARK: - Setup

extension ActivityDetailView {
    private func style() {
        backgroundColor = .systemBackground

        goHomeButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "홈으로 가기"
            config.baseBackgroundColor = .action001
            config.baseForegroundColor = .neutralWhite
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 0, bottom: 19, trailing: 0)
            $0.configuration = config
            $0.isHidden = true  // 기본적으로 숨김
        }

        scrollView.do {
            $0.showsVerticalScrollIndicator = true
        }

        contentView.do {
            $0.backgroundColor = .systemBackground
        }

        userInfoView.do {
            $0.isHidden = true  // 기본적으로 숨김 (userInfo가 있을 때만 표시)
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

        imageContainerView.do {
            $0.backgroundColor = .clear
        }

        imageView.do {
            $0.contentMode = .scaleAspectFit // 원본 비율 유지
            $0.clipsToBounds = true
            $0.backgroundColor = .bg003
            $0.layer.cornerRadius = 12
        }

        stickerImageView.do {
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

        reactionUsersScrollView.do {
            $0.isHidden = true
        }
    }

    private func layout() {
        // 홈으로 가기 버튼
        addSubview(goHomeButton)

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        // 반응 버튼 (단일 보기 모드용)
        addSubview(reactionUsersScrollView)
        addSubview(reactionButtonsView)

        // 초기 제약 조건 설정
        updateScrollViewConstraints()

        // 반응 버튼 제약 (단일 보기 모드일 때만 활성화됨)
        reactionButtonsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(Layout.reactionBarHeight)
        }

        reactionUsersScrollView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(reactionButtonsView.snp.top)
            $0.height.equalTo(0)
        }

        // 홈으로 가기 버튼
        goHomeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
        }

        // Content view
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // Add subviews to content view
        contentView.addSubview(userInfoView)
        contentView.addSubview(hobbyNameContainerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageContainerView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(memoContainerView)
        contentView.addSubview(memoStickerImageView)

        // Hobby name container and label
        hobbyNameContainerView.addSubview(hobbyNameLabel)

        // Image container (with padding)
        imageContainerView.addSubview(imageView)
        imageView.addSubview(stickerImageView)

        // User info view (profile + nickname)
        userInfoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
            $0.height.equalTo(24)
        }

        // Hobby name container (category badge)
        hobbyNameContainerView.snp.makeConstraints {
            $0.top.equalTo(userInfoView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        }

        // Hobby name label
        hobbyNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalToSuperview().offset(6)
            $0.trailing.equalToSuperview().offset(-6)
            $0.bottom.equalToSuperview().offset(-4)
        }

        // Title at top left (below hobbyNameContainerView)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(hobbyNameContainerView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // Image container constraints (below title)
        imageContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }

        // Image with padding and corner radius (원본 비율)
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(300) // 초기값, 이미지 로드 후 업데이트
            $0.bottom.equalToSuperview()
        }

        // Sticker on image (bottom-right with offset)
        stickerImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.size.equalTo(80)
        }

        // Date label (below image by default)
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(imageContainerView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // Memo container with background
        memoContainerView.addSubview(contentLabel)

        memoContainerView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }

        // Content label inside memo container (텍스트만, bottom 제약 없음)
        contentLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // Memo sticker (when no image - contentView의 직접 자식, 제약으로만 위치 제어)
        memoStickerImageView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(80)
        }
    }

    /// 스크롤뷰 제약 조건을 모드에 맞게 업데이트
    private func updateScrollViewConstraints() {
        scrollView.snp.remakeConstraints {
            // 상단은 항상 내비바 높이만큼 여백 (Safe Area 기준)
            $0.top.equalTo(safeAreaLayoutGuide).offset(Layout.navBarHeight)
            $0.leading.trailing.equalToSuperview()

            if displayMode == .afterRecord {
                // 기록 완료 모드: 홈 가기 버튼 위까지
                $0.bottom.equalTo(goHomeButton.snp.top).offset(-16)
            } else if isPagingMode {
                // 페이징 모드: 부모의 반응 버튼 위까지 (Safe Area 기준)
                $0.bottom.equalTo(safeAreaLayoutGuide).offset(-Layout.reactionBarHeight)
            } else {
                // 단일 모드: 본인의 반응 버튼 위까지 (Safe Area 기준)
                $0.bottom.equalTo(safeAreaLayoutGuide).offset(-Layout.reactionBarHeight)
            }
        }
    }
}

// MARK: - Public Methods

extension ActivityDetailView {

    /// RefreshControl 설정
    func setRefreshControl(_ refreshControl: UIRefreshControl) {
        scrollView.refreshControl = refreshControl
    }

    /// RefreshControl 종료
    func endRefreshing() {
        scrollView.refreshControl?.endRefreshing()
    }

    /// 화면 표시 모드 설정
    func setDisplayMode(_ mode: DisplayMode) {
        displayMode = mode
        updateScrollViewConstraints()
    }

    /// 페이징 모드 설정 (부모에서 관리할 경우 버튼 숨김)
    func setPagingMode(_ enabled: Bool) {
        isPagingMode = enabled
        reactionButtonsView.isHidden = enabled
        reactionUsersScrollView.isHidden = enabled
        updateScrollViewConstraints()
    }
}
