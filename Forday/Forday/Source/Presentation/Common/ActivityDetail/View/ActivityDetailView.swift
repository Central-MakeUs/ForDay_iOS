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

    // MARK: - Properties

    private var displayMode: DisplayMode = .normal

    // Custom Navigation
    private let navigationView = UIView()
    private let navigationTitleLabel = UILabel()
    let backButton = UIButton()
    let saveButton = UIButton()
    let moreButton = UIButton()

    // 홈으로 가기 버튼 (기록 완료 후 모드에서만 표시)
    let goHomeButton = UIButton()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

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

    // Reactions
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

        // Load sticker image
        if let stickerType = StickerType(fileName: detail.sticker) {
            stickerImageView.image = stickerType.image
            memoStickerImageView.image = stickerType.image
        }

        // Configure title (at top) and date
        titleLabel.setTextWithTypography(detail.activityContent, style: .header18)
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

        // Save button: 내가 쓴 글 + 이미지 있을 때만 표시
        saveButton.isHidden = !(detail.recordOwner && hasImage)

        // Configure reaction buttons
        reactionButtonsView.configure(with: detail)

        // Update layout based on type
        updateLayoutForType()
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
                $0.bottom.lessThanOrEqualToSuperview().offset(-20)
            }

        case .withoutImage:
            // 이미지 없을 때: 타이틀 아래에 날짜
            dateLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(8)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
            }
            // 메모 컨테이너 전체 너비, 스티커가 메모 안 오른쪽 하단에 위치
            memoContainerView.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.lessThanOrEqualToSuperview().offset(-20)
            }
            // 스티커가 메모 컨테이너 안 오른쪽 하단
            memoStickerImageView.snp.remakeConstraints {
                $0.trailing.equalTo(memoContainerView).offset(-8)
                $0.bottom.equalTo(memoContainerView).offset(-8)
                $0.size.equalTo(64)
            }

        case .withoutImageAndMemo:
            // 이미지도 메모도 없을 때: 타이틀 아래에 날짜, 스티커는 날짜 아래
            dateLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(8)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
            }
            memoStickerImageView.snp.remakeConstraints {
                $0.trailing.equalToSuperview().offset(-20)
                $0.top.equalTo(dateLabel.snp.bottom).offset(16)
                $0.size.equalTo(80)
            }
        }
    }
}

// MARK: - Setup

extension ActivityDetailView {
    private func style() {
        backgroundColor = .systemBackground

        // Custom Navigation
        navigationView.do {
            $0.backgroundColor = .systemBackground
        }

        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral900
        }

        moreButton.do {
            $0.setImage(.Icon.threeDotVertical, for: .normal)
            $0.tintColor = .neutral900
        }

        saveButton.do {
            $0.setImage(.Icon.save, for: .normal)
            $0.tintColor = .neutral900
            $0.isHidden = true  // 기본적으로 숨김 (내가 쓴 글 + 이미지 있을 때만 표시)
        }

        navigationTitleLabel.do {
            $0.setTextWithTypography("내 활동 보기", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
            $0.isHidden = true  // 기본적으로 숨김
        }

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
    }

    private func layout() {
        // Custom Navigation
        addSubview(navigationView)
        navigationView.addSubview(backButton)
        navigationView.addSubview(saveButton)
        navigationView.addSubview(moreButton)
        navigationView.addSubview(navigationTitleLabel)

        // 홈으로 가기 버튼
        addSubview(goHomeButton)

        addSubview(scrollView)
        addSubview(reactionUsersScrollView)
        addSubview(reactionButtonsView)
        scrollView.addSubview(contentView)

        // Navigation view constraints
        navigationView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        saveButton.snp.makeConstraints {
            $0.trailing.equalTo(moreButton.snp.leading).offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        navigationTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        // Scroll view constraints
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(reactionUsersScrollView.snp.top)
        }

        // Reaction users scroll view
        reactionUsersScrollView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(reactionButtonsView.snp.top)
            $0.height.equalTo(60)
        }

        // Reaction buttons - safe area 고려
        reactionButtonsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageContainerView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(memoContainerView)
        contentView.addSubview(memoStickerImageView)

        // Image container (with padding)
        imageContainerView.addSubview(imageView)
        imageView.addSubview(stickerImageView)

        // Initially hide reaction users scroll view
        reactionUsersScrollView.isHidden = true

        // Title at top left
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
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

        // Content label inside memo container
        contentLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }

        // Memo sticker (when no image - inside memo container)
        memoStickerImageView.snp.makeConstraints {
            $0.trailing.equalTo(memoContainerView).offset(-8)
            $0.bottom.equalTo(memoContainerView).offset(-8)
            $0.size.equalTo(64)
        }
    }
}

// MARK: - Public Methods

extension ActivityDetailView {

    /// 화면 표시 모드 설정
    func setDisplayMode(_ mode: DisplayMode) {
        displayMode = mode
        updateDisplayMode()
    }

    private func updateDisplayMode() {
        switch displayMode {
        case .normal:
            // 일반 모드: 네비게이션 버튼 표시, 반응 버튼 표시, 홈으로 가기 숨김
            backButton.isHidden = false
            moreButton.isHidden = false
            // saveButton visibility is controlled by configure(with:) based on recordOwner && hasImage
            navigationTitleLabel.isHidden = true
            reactionButtonsView.isHidden = false
            reactionUsersScrollView.isHidden = false
            goHomeButton.isHidden = true

            // 스크롤뷰 하단 여백 조정
            scrollView.snp.remakeConstraints {
                $0.top.equalTo(navigationView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(reactionUsersScrollView.snp.top)
            }

        case .afterRecord:
            // 기록 완료 후 모드: 네비게이션 버튼 숨김, 타이틀만 표시, 반응 버튼 숨김, 홈으로 가기 표시
            backButton.isHidden = true
            moreButton.isHidden = true
            saveButton.isHidden = true
            navigationTitleLabel.isHidden = false
            reactionButtonsView.isHidden = true
            reactionUsersScrollView.isHidden = true
            goHomeButton.isHidden = false

            // 스크롤뷰 하단 여백 조정 (홈으로 가기 버튼 위까지)
            scrollView.snp.remakeConstraints {
                $0.top.equalTo(navigationView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(goHomeButton.snp.top).offset(-16)
            }
        }
    }
}

#if DEBUG
#Preview("ActivityDetailView - Basic") {
    let view = ActivityDetailView()
    view.configure(with: .preview)
    return view
}

#Preview("ActivityDetailView - Scraped") {
    let view = ActivityDetailView()
    view.configure(with: .previewScraped)
    return view
}

#Preview("ActivityDetailView - All Reactions") {
    let view = ActivityDetailView()
    view.configure(with: .previewWithAllReactions)
    return view
}
#endif
