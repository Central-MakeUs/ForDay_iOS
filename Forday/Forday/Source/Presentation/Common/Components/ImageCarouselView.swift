//
//  ImageCarouselView.swift
//  Forday
//
//  Created by Subeen on 6/27/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ImageCarouselView: UIView {

    // MARK: - Properties

    private var images: [ActivityDetailImage] = []
    private var currentIndex: Int = 0
    private var imageViews: [UIImageView] = []

    /// 스티커 이미지 (외부에서 설정)
    var stickerImage: UIImage? {
        didSet {
            stickerImageView.image = stickerImage
        }
    }

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let stickerImageView = UIImageView()

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

    func configure(with images: [ActivityDetailImage]) {
        self.images = images

        // 기존 이미지 뷰 제거
        imageViews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()

        guard !images.isEmpty else {
            isHidden = true
            return
        }

        isHidden = false

        // 이미지 뷰 추가
        for (index, image) in images.enumerated() {
            let imageView = createImageView(for: image, at: index)
            imageViews.append(imageView)
            scrollView.addSubview(imageView)
        }

        // 페이지 컨트롤 설정
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        pageControl.isHidden = images.count <= 1

        // 스티커를 맨 위로 올리기
        bringSubviewToFront(stickerImageView)

        // 레이아웃 업데이트
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func createImageView(for image: ActivityDetailImage, at index: Int) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .bg003
        imageView.layer.cornerRadius = 16

        // 이미지 로드
        if let url = URL(string: image.imageUrl) {
            imageView.kf.setImage(with: url)
        }

        return imageView
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        // 각 이미지 뷰의 크기와 위치 설정
        let imageWidth = bounds.width
        let imageHeight = scrollView.bounds.height
        guard imageWidth > 0, imageHeight > 0 else { return }

        for (index, imageView) in imageViews.enumerated() {
            imageView.frame = CGRect(
                x: CGFloat(index) * imageWidth,
                y: 0,
                width: imageWidth,
                height: imageHeight
            )
        }

        scrollView.contentSize = CGSize(
            width: imageWidth * CGFloat(imageViews.count),
            height: imageHeight
        )
    }
}

// MARK: - Setup

extension ImageCarouselView {
    private func style() {
        backgroundColor = .clear

        scrollView.do {
            $0.isPagingEnabled = true
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.delegate = self
            $0.bounces = false
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 16
        }

        pageControl.do {
            $0.currentPageIndicatorTintColor = .neutral900
            $0.pageIndicatorTintColor = .neutral300
            $0.isUserInteractionEnabled = false
        }

        stickerImageView.do {
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        addSubview(scrollView)
        addSubview(pageControl)
        addSubview(stickerImageView)

        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        pageControl.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(8)
            $0.bottom.equalToSuperview()
        }

        stickerImageView.snp.makeConstraints {
            $0.trailing.equalTo(scrollView).offset(-16)
            $0.bottom.equalTo(scrollView).offset(-16)
            $0.size.equalTo(80)
        }
    }

    /// 이미지 높이 설정 (외부에서 호출)
    func updateScrollViewHeight(_ height: CGFloat) {
        scrollView.snp.remakeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(height)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
}

// MARK: - UIScrollViewDelegate

extension ImageCarouselView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.bounds.width > 0 else { return }
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl.currentPage = page
        currentIndex = page
    }
}

// MARK: - Public Methods

extension ImageCarouselView {
    /// 첫 번째 이미지 URL 반환 (공유용)
    var firstImageUrl: String? {
        return images.first?.imageUrl
    }

    /// 현재 보고 있는 이미지의 URL 반환
    var currentImageUrl: String? {
        guard currentIndex < images.count else { return nil }
        return images[currentIndex].imageUrl
    }
}
