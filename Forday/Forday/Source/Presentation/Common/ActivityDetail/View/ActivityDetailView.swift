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

        // 이미지 높이가 변하면 전체 레이아웃 다시 계산하여 contentSize 갱신
        setNeedsLayout()
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
            // 메모 컨테이너 전체 너비
            memoContainerView.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.equalToSuperview().offset(-40) // 확실하게 바닥에 고정 (여백 40)
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
            }
            // contentView 바닥과 연결
            memoContainerView.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(-40)
            }

        case .withoutImageAndMemo:
            dateLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(24)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
            }
            memoStickerImageView.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(24)
                $0.trailing.equalToSuperview().offset(-20)
                $0.size.equalTo(80)
                $0.bottom.equalToSuperview().offset(-40)
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

        imageContainerView.do {
            $0.backgroundColor = .clear
        }

        imageView.do {
            $0.contentMode = .scaleAspectFit
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
        addSubview(goHomeButton)
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        addSubview(reactionUsersScrollView)
        addSubview(reactionButtonsView)

        updateScrollViewConstraints()

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
        contentView.addSubview(imageContainerView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(memoContainerView)
        contentView.addSubview(memoStickerImageView)

        hobbyNameContainerView.addSubview(hobbyNameLabel)
        imageContainerView.addSubview(imageView)
        imageView.addSubview(stickerImageView)

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

        imageContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(300)
            $0.bottom.equalToSuperview()
        }

        stickerImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.size.equalTo(80)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(imageContainerView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
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
            $0.top.equalTo(safeAreaLayoutGuide).offset(Layout.navBarHeight)
            $0.leading.trailing.equalToSuperview()

            if displayMode == .afterRecord {
                $0.bottom.equalTo(goHomeButton.snp.top).offset(-16)
            } else {
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
        updateScrollViewConstraints()
    }

    func setPagingMode(_ enabled: Bool) {
        isPagingMode = enabled
        reactionButtonsView.isHidden = enabled
        reactionUsersScrollView.isHidden = enabled
        updateScrollViewConstraints()
    }
}
