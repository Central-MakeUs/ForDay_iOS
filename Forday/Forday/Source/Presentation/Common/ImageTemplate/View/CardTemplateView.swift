//
//  CardTemplateView.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import UIKit
import SnapKit
import Then

/// 카드형 이미지 템플릿 뷰
/// Figma 기준 사이즈: 250.5 x 360
final class CardTemplateView: UIView {

    // MARK: - Constants

    private enum Layout {
        // 템플릿 전체 크기
        static let templateSize = CGSize(width: 250.5, height: 360)
        static let backgroundHorizontalPadding: CGFloat = 20  // px-20
        static let backgroundVerticalPadding: CGFloat = 28    // py-28

        // 카드 컨테이너
        static let cardWidth: CGFloat = 210.5  // 250.5 - 40
        static let cardCornerRadius: CGFloat = 12
        static let cardPadding: CGFloat = 8
        static let cardSectionGap: CGFloat = 24  // gap between (photo+text) and logo

        // 사진 영역 (w-full x h-200)
        static let photoWidth: CGFloat = 194.5   // cardWidth - cardPadding*2
        static let photoHeight: CGFloat = 200
        static let photoCornerRadius: CGFloat = 12

        // 스티커 (Figma: left 132.47, top 132.47)
        static let stickerSize: CGFloat = 48
        static let stickerRightOffset: CGFloat = 14   // 194.5 - 132.47 - 48 ≈ 14
        static let stickerBottomOffset: CGFloat = 19  // 200 - 132.47 - 48 ≈ 19

        // 텍스트 영역
        static let photoTextGap: CGFloat = 8     // gap between photo and text
        static let titleDateGap: CGFloat = 4     // gap between title and date

        // 로고
        static let logoWidth: CGFloat = 48
        static let logoHeight: CGFloat = 16
    }

    // MARK: - UI Components

    /// 배경 이미지 (그라데이션)
    private let backgroundImageView = UIImageView()

    /// 흰색 카드 컨테이너
    private let cardContainerView = UIView()

    /// 사진 영역
    private let photoContainerView = UIView()
    private let photoImageView = UIImageView()

    /// 스티커
    private let stickerImageView = UIImageView()

    /// 텍스트 영역
    private let textStackView = UIStackView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()

    /// 포데이 로고
    private let logoImageView = UIImageView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return Layout.templateSize
    }

    // MARK: - Configuration

    /// 템플릿 데이터 설정
    /// - Parameters:
    ///   - image: 사진 이미지 (scaleAspectFill로 194.5x200 영역에 맞춤)
    ///   - title: 활동 제목
    ///   - date: 날짜 문자열 (예: "2026-01-11 12:06")
    ///   - stickerType: 스티커 타입
    func configure(
        image: UIImage,
        title: String,
        date: String,
        stickerType: StickerType
    ) {
        // 배경 이미지 설정
        backgroundImageView.image = stickerType.cardTemplateBackground

        // 사진 설정 (scaleAspectFill로 영역에 맞춤)
        photoImageView.image = image

        // 스티커 설정
        stickerImageView.image = stickerType.image

        // 텍스트 설정
        titleLabel.setTextWithTypography(title, style: .header16)
        dateLabel.setTextWithTypography(date, style: .label12)

        // 로고 설정
        logoImageView.image = .Template.fordayKRLogoOrange
    }

    // MARK: - Render to Image

    /// 뷰를 UIImage로 렌더링
    /// - Returns: 렌더링된 UIImage
    func renderToImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: Layout.templateSize)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}

// MARK: - Setup

extension CardTemplateView {
    private func style() {
        backgroundColor = .clear

        backgroundImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }

        cardContainerView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = Layout.cardCornerRadius
            $0.clipsToBounds = true
        }

        photoContainerView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = Layout.photoCornerRadius
            $0.clipsToBounds = true
        }

        photoImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = Layout.photoCornerRadius
        }

        stickerImageView.do {
            $0.contentMode = .scaleAspectFit
        }

        textStackView.do {
            $0.axis = .vertical
            $0.spacing = Layout.titleDateGap
            $0.alignment = .fill
        }

        titleLabel.do {
            $0.textColor = .neutral800
            $0.numberOfLines = 0
        }

        dateLabel.do {
            $0.textColor = .neutral500
        }

        logoImageView.do {
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        addSubview(backgroundImageView)
        backgroundImageView.addSubview(cardContainerView)

        cardContainerView.addSubview(photoContainerView)
        photoContainerView.addSubview(photoImageView)
        photoContainerView.addSubview(stickerImageView)

        cardContainerView.addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(dateLabel)

        cardContainerView.addSubview(logoImageView)

        // 배경 이미지 - 전체 크기
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(Layout.templateSize.width)
            $0.height.equalTo(Layout.templateSize.height)
        }

        // 카드 컨테이너 - 배경 중앙 (px-20, py-28)
        cardContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.backgroundHorizontalPadding)
            $0.trailing.equalToSuperview().offset(-Layout.backgroundHorizontalPadding)
            $0.top.equalToSuperview().offset(Layout.backgroundVerticalPadding)
            $0.bottom.equalToSuperview().offset(-Layout.backgroundVerticalPadding)
        }

        // 사진 영역 - 카드 내부 상단 (w-full x h-200)
        photoContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(Layout.cardPadding)
            $0.height.equalTo(Layout.photoHeight)
        }

        photoImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 스티커 - 사진 영역 우하단 (Figma: left 132.47, top 132.47)
        stickerImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Layout.stickerRightOffset)
            $0.bottom.equalToSuperview().offset(-Layout.stickerBottomOffset)
            $0.size.equalTo(Layout.stickerSize)
        }

        // 텍스트 영역 - 사진 아래 (gap-8)
        textStackView.snp.makeConstraints {
            $0.top.equalTo(photoContainerView.snp.bottom).offset(Layout.photoTextGap)
            $0.leading.trailing.equalToSuperview().inset(Layout.cardPadding)
        }

        // 로고 - 카드 하단에서 고정 위치
        logoImageView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-Layout.cardPadding)
            $0.leading.equalToSuperview().offset(Layout.cardPadding)
            $0.width.equalTo(Layout.logoWidth)
            $0.height.equalTo(Layout.logoHeight)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("CardTemplateView - Smile") {
    let view = CardTemplateView()
    // TODO: Add preview configuration when assets are available
    return view
}
#endif
