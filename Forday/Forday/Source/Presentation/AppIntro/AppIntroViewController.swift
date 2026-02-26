//
//  AppIntroViewController.swift
//  Forday
//
//  Created by Subeen on 2/26/26.
//

import UIKit
import SnapKit
import Then

/// 앱 소개 화면 (스와이프 가능한 페이지)
final class AppIntroViewController: UIViewController {

    // MARK: - Properties

    /// 앱 소개 완료 후 호출되는 콜백
    var onIntroComplete: (() -> Void)?

    private let pages: [UIImage?] = [
        .AppIntro.page1,
        .AppIntro.page2,
        .AppIntro.page3,
        .AppIntro.page4,
        .AppIntro.page5
    ]

    private var currentPage = 0 {
        didSet {
            updatePageIndicator()
        }
    }

    /// 전환 중 여부 (중복 방지)
    private var isTransitioning = false

    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(AppIntroPageCell.self, forCellWithReuseIdentifier: AppIntroPageCell.identifier)
        return cv
    }()

    private let pageIndicatorStackView = UIStackView()
    private var indicatorViews: [UIView] = []

    // MARK: - Constants

    private enum Metric {
        static let imageTopOffset: CGFloat = 20
        static let imageHorizontalInset: CGFloat = 30
        static let imageHeight: CGFloat = 649
        static let indicatorTopSpacing: CGFloat = 15
        static let indicatorSize: CGFloat = 8
        static let indicatorSpacing: CGFloat = 6
        static let swipeThreshold: CGFloat = 100
        static let transitionDuration: TimeInterval = 0.3
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupPageIndicator()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - Setup

extension AppIntroViewController {
    private func style() {
        view.backgroundColor = .bg004

        pageIndicatorStackView.do {
            $0.axis = .horizontal
            $0.spacing = Metric.indicatorSpacing
            $0.alignment = .center
            $0.distribution = .fill
        }
    }

    private func layout() {
        view.addSubview(collectionView)
        view.addSubview(pageIndicatorStackView)

        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Metric.imageTopOffset)
            $0.leading.trailing.equalToSuperview().inset(Metric.imageHorizontalInset)
            $0.height.equalTo(Metric.imageHeight)
        }

        pageIndicatorStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(collectionView.snp.bottom).offset(Metric.indicatorTopSpacing)
            $0.height.equalTo(Metric.indicatorSize)
        }
    }

    private func setupPageIndicator() {
        // 기존 인디케이터 제거
        indicatorViews.forEach { $0.removeFromSuperview() }
        indicatorViews.removeAll()

        // 페이지 수만큼 원형 인디케이터 생성
        for index in 0..<pages.count {
            let indicatorView = UIView()
            indicatorView.backgroundColor = index == 0 ? .neutral600 : .neutral200
            indicatorView.layer.cornerRadius = Metric.indicatorSize / 2

            indicatorView.snp.makeConstraints {
                $0.size.equalTo(Metric.indicatorSize)
            }

            pageIndicatorStackView.addArrangedSubview(indicatorView)
            indicatorViews.append(indicatorView)
        }
    }

    private func updatePageIndicator() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }

            for (index, indicatorView) in self.indicatorViews.enumerated() {
                let isActive = index == self.currentPage
                indicatorView.backgroundColor = isActive ? .neutral600 : .neutral200
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension AppIntroViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AppIntroPageCell.identifier,
            for: indexPath
        ) as? AppIntroPageCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: pages[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AppIntroViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return collectionView.bounds.size
    }
}

// MARK: - UIScrollViewDelegate

extension AppIntroViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0, !isTransitioning else { return }

        let page = Int(round(scrollView.contentOffset.x / pageWidth))
        if page != currentPage && page >= 0 && page < pages.count {
            currentPage = page
        }

        // 마지막 페이지에서 오버스크롤 시 뷰 전체를 왼쪽으로 이동
        let maxOffset = CGFloat(pages.count - 1) * pageWidth
        let overscroll = scrollView.contentOffset.x - maxOffset

        if currentPage == pages.count - 1 && overscroll > 0 {
            // 오버스크롤 정도에 따라 뷰 이동 (저항감 적용)
            let translation = -overscroll * 0.5
            view.transform = CGAffineTransform(translationX: translation, y: 0)
        } else {
            view.transform = .identity
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }

        let maxOffset = CGFloat(pages.count - 1) * pageWidth
        let overscroll = scrollView.contentOffset.x - maxOffset

        // 마지막 페이지에서 threshold 이상 스와이프하면 전환
        if currentPage == pages.count - 1 && overscroll > Metric.swipeThreshold {
            completeIntroWithAnimation()
        } else {
            // threshold 미만이면 원래 위치로 복귀
            UIView.animate(withDuration: 0.2) {
                self.view.transform = .identity
            }
        }
    }
}

// MARK: - Private Methods

extension AppIntroViewController {
    private func completeIntroWithAnimation() {
        guard !isTransitioning, onIntroComplete != nil else { return }
        isTransitioning = true

        // 스크롤 비활성화
        collectionView.isScrollEnabled = false

        // 뷰를 왼쪽으로 완전히 밀어내는 애니메이션
        UIView.animate(
            withDuration: Metric.transitionDuration,
            delay: 0,
            options: .curveEaseIn
        ) {
            self.view.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
        } completion: { _ in
            self.completeIntro()
        }
    }

    private func completeIntro() {
        // 앱 소개 본 것으로 표시
        AppLaunchStorage.shared.markAppIntroAsSeen()

        // 콜백 호출
        let callback = onIntroComplete
        onIntroComplete = nil
        callback?()
    }
}

#if DEBUG
#Preview {
    AppIntroViewController()
}
#endif
