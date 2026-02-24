//
//  GradientTemplateView.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import UIKit
import SnapKit
import Then

/// 그라데이션 스타일 이미지 템플릿 뷰
/// 사진 위에 그라데이션 오버레이와 텍스트를 표시
final class GradientTemplateView: UIView {

    // MARK: - Constants

    private enum Layout {
        // 템플릿 전체 크기 (CardTemplateView와 동일)
        static let templateSize = CGSize(width: 250.5, height: 360)
        static let cornerRadius: CGFloat = 16

        // 로고 (우상단)
        static let logoWidth: CGFloat = 48
        static let logoHeight: CGFloat = 16
        static let logoTopOffset: CGFloat = 16
        static let logoRightOffset: CGFloat = 16

        // 스티커
        static let stickerSize: CGFloat = 60
        static let stickerRightOffset: CGFloat = 16
        static let stickerTopOffset: CGFloat = 200

        // 텍스트 영역 (하단 기준)
        static let textLeftOffset: CGFloat = 16
        static let textBottomOffset: CGFloat = 16
        static let textWidth: CGFloat = 202
        static let titleMemoGap: CGFloat = 4
        static let memoDateGap: CGFloat = 4
    }

    // MARK: - UI Components

    /// 배경 사진
    private let photoImageView = UIImageView()

    /// 그라데이션 오버레이
    private let gradientLayer = CAGradientLayer()
    private let gradientOverlayView = UIView()

    /// 포데이 로고 (흰색)
    private let logoImageView = UIImageView()

    /// 스티커
    private let stickerImageView = UIImageView()

    /// 텍스트 영역
    private let textStackView = UIStackView()
    private let titleLabel = UILabel()
    private let memoLabel = UILabel()
    private let dateLabel = UILabel()

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

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientOverlayView.bounds
    }

    // MARK: - Configuration

    /// 템플릿 데이터 설정
    /// - Parameters:
    ///   - image: 사진 이미지 (scaleAspectFill로 전체 영역에 맞춤)
    ///   - title: 활동 제목
    ///   - memo: 메모 (1줄, 말줄임)
    ///   - date: 날짜 문자열 (예: "2026-01-11 12:06" → "2026.01.11. (토)")
    ///   - stickerType: 스티커 타입
    func configure(
        image: UIImage,
        title: String,
        memo: String?,
        date: String,
        stickerType: StickerType
    ) {
        // 사진 설정
        photoImageView.image = image

        // 그라데이션 설정
        applyGradient(for: stickerType)

        // 로고 설정 (흰색 버전)
        logoImageView.image = .Template.fordayKRLogoWhite

        // 스티커 설정
        stickerImageView.image = stickerType.image

        // 텍스트 설정
        titleLabel.setTextWithTypography(title, style: .header18)

        if let memo = memo, !memo.isEmpty {
            memoLabel.isHidden = false
            memoLabel.setTextWithTypography(memo, style: .label12)
        } else {
            memoLabel.isHidden = true
        }

        // 날짜 형식 변환: "2026-01-11 12:06" → "2026.01.11. (토)"
        dateLabel.setTextWithTypography(date.toTemplateDate(), style: .label10)
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

    // MARK: - Private Methods

    private func applyGradient(for stickerType: StickerType) {
        let gradient = stickerType.templateGradient
        gradientLayer.colors = gradient.colors.map { $0.cgColor }
        gradientLayer.startPoint = gradient.start.point
        gradientLayer.endPoint = gradient.end.point
        gradientLayer.locations = gradient.locations
    }
}

// MARK: - Setup

extension GradientTemplateView {
    private func style() {
        backgroundColor = .clear
        layer.cornerRadius = Layout.cornerRadius
        clipsToBounds = true

        photoImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }

        gradientOverlayView.do {
            $0.backgroundColor = .clear
            $0.layer.addSublayer(gradientLayer)
        }

        logoImageView.do {
            $0.contentMode = .scaleAspectFit
        }

        stickerImageView.do {
            $0.contentMode = .scaleAspectFit
        }

        textStackView.do {
            $0.axis = .vertical
            $0.spacing = Layout.titleMemoGap
            $0.alignment = .leading
        }

        titleLabel.do {
            $0.textColor = .white
            $0.numberOfLines = 2
            $0.lineBreakMode = .byTruncatingTail
        }

        memoLabel.do {
            $0.textColor = .white
            $0.numberOfLines = 1
            $0.lineBreakMode = .byTruncatingTail
        }

        dateLabel.do {
            $0.textColor = UIColor.white.withAlphaComponent(0.6)
        }
    }

    private func layout() {
        addSubview(photoImageView)
        addSubview(gradientOverlayView)
        addSubview(logoImageView)
        addSubview(stickerImageView)
        addSubview(textStackView)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(memoLabel)
        textStackView.addArrangedSubview(dateLabel)

        // 사진 - 전체 영역
        photoImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 그라데이션 오버레이 - 전체 영역
        gradientOverlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 로고 - 우상단
        logoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.logoTopOffset)
            $0.trailing.equalToSuperview().offset(-Layout.logoRightOffset)
            $0.width.equalTo(Layout.logoWidth)
            $0.height.equalTo(Layout.logoHeight)
        }

        // 스티커
        stickerImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.stickerTopOffset)
            $0.trailing.equalToSuperview().offset(-Layout.stickerRightOffset)
            $0.size.equalTo(Layout.stickerSize)
        }

        // 텍스트 영역 (하단 기준, 타이틀 길어지면 위로 확장)
        textStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-Layout.textBottomOffset)
            $0.leading.equalToSuperview().offset(Layout.textLeftOffset)
            $0.width.equalTo(Layout.textWidth)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("GradientTemplateView - Smile") {
    let view = GradientTemplateView()
    return view
}
#endif
