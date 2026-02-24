//
//  ImageTemplateSelectorView.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import UIKit
import SnapKit
import Then

/// 이미지 템플릿 선택 화면 뷰
final class ImageTemplateSelectorView: UIView {

    // MARK: - Constants

    private enum Layout {
        static let templateWidth: CGFloat = 250.5
        static let templateHeight: CGFloat = 360
        static let templateSpacing: CGFloat = 20
    }

    // MARK: - Properties

    private(set) var currentPage: Int = 0

    // MARK: - UI Components

    // Navigation
    private let navigationView = UIView()
    let backButton = UIButton()
    private let titleLabel = UILabel()

    // Header
    private let headerStackView = UIStackView()
    private let headerTitleLabel = UILabel()
    private let headerSubtitleLabel = UILabel()

    // Template Preview - Horizontal Scroll
    private let templateContainerView = UIView()
    private let templateScrollView = UIScrollView()
    private let templateStackView = UIStackView()
    let cardTemplateView = CardTemplateView()
    let gradientTemplateView = GradientTemplateView()

    // Page Indicator
    private let pageIndicatorStackView = UIStackView()
    private var pageIndicators: [UIView] = []

    // Bottom Button
    private let bottomGradientView = UIView()
    let saveButton = UIButton()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupPageIndicators()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// 템플릿 프리뷰 설정
    func configureTemplate(
        image: UIImage,
        title: String,
        memo: String?,
        date: String,
        stickerType: StickerType
    ) {
        // Template 1: Card style
        cardTemplateView.configure(
            image: image,
            title: title,
            date: date,
            stickerType: stickerType
        )

        // Template 2: Gradient style
        gradientTemplateView.configure(
            image: image,
            title: title,
            memo: memo,
            date: date,
            stickerType: stickerType
        )
    }

    /// 현재 선택된 템플릿 뷰 반환
    func currentTemplateView() -> UIView {
        return currentPage == 0 ? cardTemplateView : gradientTemplateView
    }

    /// 현재 선택된 템플릿 이미지 렌더링
    func renderCurrentTemplate() -> UIImage? {
        if currentPage == 0 {
            return cardTemplateView.renderToImage()
        } else {
            return gradientTemplateView.renderToImage()
        }
    }
}

// MARK: - Setup

extension ImageTemplateSelectorView {
    private func style() {
        backgroundColor = .bg001

        // Navigation
        navigationView.do {
            $0.backgroundColor = .bg001
        }

        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral900
        }

        titleLabel.do {
            $0.setTextWithTypography("저장하기", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        // Header
        headerStackView.do {
            $0.axis = .vertical
            $0.spacing = 10
            $0.alignment = .leading
        }

        headerTitleLabel.do {
            $0.setTextWithTypography("원하는 카드 프레임을 골라주세요.", style: .header20)
            $0.textColor = .neutral900
        }

        headerSubtitleLabel.do {
            $0.setTextWithTypography("나의 활동기록을 카드로 공유할 수 있어요.", style: .label14)
            $0.textColor = .neutral800
        }

        // Template Container
        templateContainerView.do {
            $0.backgroundColor = .clear
        }

        // Template ScrollView
        templateScrollView.do {
            $0.isPagingEnabled = false  // 커스텀 스냅 사용
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.delegate = self
            $0.clipsToBounds = false
            $0.decelerationRate = .fast
        }

        templateStackView.do {
            $0.axis = .horizontal
            $0.spacing = Layout.templateSpacing
            $0.alignment = .center
        }

        // Page Indicator
        pageIndicatorStackView.do {
            $0.axis = .horizontal
            $0.spacing = 6
            $0.alignment = .center
        }

        // Bottom
        bottomGradientView.do {
            $0.backgroundColor = .clear
        }

        saveButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "저장하기"
            config.baseBackgroundColor = .action001
            config.baseForegroundColor = .neutralWhite
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 0, bottom: 19, trailing: 0)
            $0.configuration = config
        }
    }

    private func layout() {
        addSubview(navigationView)
        navigationView.addSubview(backButton)
        navigationView.addSubview(titleLabel)

        addSubview(headerStackView)
        headerStackView.addArrangedSubview(headerTitleLabel)
        headerStackView.addArrangedSubview(headerSubtitleLabel)

        addSubview(templateContainerView)
        templateContainerView.addSubview(templateScrollView)
        templateScrollView.addSubview(templateStackView)
        templateStackView.addArrangedSubview(cardTemplateView)
        templateStackView.addArrangedSubview(gradientTemplateView)

        addSubview(pageIndicatorStackView)

        addSubview(bottomGradientView)
        addSubview(saveButton)

        // Navigation
        navigationView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        // Header
        headerStackView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // Template Container
        templateContainerView.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.templateHeight + 20)  // 여유 공간
        }

        // Template ScrollView - 중앙 정렬
        templateScrollView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.templateHeight)
        }

        templateStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        // Template Views - 고정 크기
        cardTemplateView.snp.makeConstraints {
            $0.width.equalTo(Layout.templateWidth)
            $0.height.equalTo(Layout.templateHeight)
        }

        gradientTemplateView.snp.makeConstraints {
            $0.width.equalTo(Layout.templateWidth)
            $0.height.equalTo(Layout.templateHeight)
        }

        // Page Indicator
        pageIndicatorStackView.snp.makeConstraints {
            $0.top.equalTo(templateContainerView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }

        // Bottom Gradient
        bottomGradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(88)
        }

        // Save Button
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
        }
    }

    private func setupPageIndicators() {
        let numberOfPages = 2

        for i in 0..<numberOfPages {
            let indicator = UIView()
            indicator.layer.cornerRadius = 4
            indicator.backgroundColor = i == 0 ? .neutral600 : .neutral300
            pageIndicatorStackView.addArrangedSubview(indicator)

            indicator.snp.makeConstraints {
                if i == 0 {
                    $0.width.equalTo(14)
                    $0.height.equalTo(8)
                } else {
                    $0.size.equalTo(8)
                }
            }

            pageIndicators.append(indicator)
        }
    }

    private func updatePageIndicator(to page: Int) {
        for (index, indicator) in pageIndicators.enumerated() {
            let isActive = index == page
            indicator.backgroundColor = isActive ? .neutral600 : .neutral300

            indicator.snp.remakeConstraints {
                if isActive {
                    $0.width.equalTo(14)
                    $0.height.equalTo(8)
                } else {
                    $0.size.equalTo(8)
                }
            }
        }

        UIView.animate(withDuration: 0.2) {
            self.pageIndicatorStackView.layoutIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupBottomGradient()
        setupScrollViewContentInset()
    }

    private func setupBottomGradient() {
        // Remove existing gradient layers
        bottomGradientView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bottomGradientView.bounds
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.locations = [0.0, 0.62]
        bottomGradientView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupScrollViewContentInset() {
        // 화면 너비 기준으로 좌우 여백 계산하여 중앙 정렬
        let screenWidth = bounds.width
        let itemWidth = Layout.templateWidth
        let spacing = Layout.templateSpacing
        let horizontalInset = (screenWidth - itemWidth) / 2

        templateScrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: horizontalInset,
            bottom: 0,
            right: horizontalInset
        )

        // 스냅 포인트 설정을 위한 content size
        let contentWidth = (itemWidth + spacing) * 2 - spacing
        templateStackView.snp.updateConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ImageTemplateSelectorView: UIScrollViewDelegate {
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let pageWidth = Layout.templateWidth + Layout.templateSpacing
        let inset = scrollView.contentInset.left

        // 현재 위치에서 가장 가까운 페이지 계산
        let currentOffset = targetContentOffset.pointee.x + inset
        var targetPage = round(currentOffset / pageWidth)

        // 속도에 따라 페이지 조정
        if velocity.x > 0.3 {
            targetPage = min(targetPage + 1, 1)
        } else if velocity.x < -0.3 {
            targetPage = max(targetPage - 1, 0)
        }

        targetPage = max(0, min(targetPage, 1))

        // 스냅 위치 계산
        let targetX = targetPage * pageWidth - inset
        targetContentOffset.pointee.x = targetX

        currentPage = Int(targetPage)
        updatePageIndicator(to: currentPage)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = Layout.templateWidth + Layout.templateSpacing
        let page = Int(round((scrollView.contentOffset.x + scrollView.contentInset.left) / pageWidth))
        currentPage = max(0, min(page, 1))
        updatePageIndicator(to: currentPage)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("ImageTemplateSelectorView") {
    let view = ImageTemplateSelectorView()
    return view
}
#endif
