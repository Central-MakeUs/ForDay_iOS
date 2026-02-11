//
//  OnboardingCompleteView.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import UIKit
import SnapKit
import Then

class OnboardingCompleteView: UIView {

    // Properties

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    let pageControl = UIPageControl()
    let startButton = UIButton()

    // Data
    let slideData: [IntroCharacter] = IntroCharacter.allCases
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension OnboardingCompleteView {
    private func style() {
        backgroundColor = .neutralWhite
        
        titleLabel.do {
            $0.setTextWithTypography("그리고.. 포데이를 함께 할 포비들이에요!", style: .header20)
            $0.textColor = .neutral900
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
        
        subtitleLabel.do {
            $0.setTextWithTypography("취미 스티커 콜렉션을 포비로 채워보세요.\n뿌듯하실걸요?", style: .label14)
            $0.textColor = .neutral800
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
        
        collectionView.do {
            $0.backgroundColor = .clear
            $0.isPagingEnabled = false
            $0.showsHorizontalScrollIndicator = false
            $0.decelerationRate = .fast
            $0.delegate = self
            $0.dataSource = self
            $0.register(OnboardingSlideCell.self, forCellWithReuseIdentifier: OnboardingSlideCell.identifier)
        }

        pageControl.do {
            $0.numberOfPages = slideData.count
            $0.currentPage = 0
            $0.pageIndicatorTintColor = .neutral200
            $0.currentPageIndicatorTintColor = .neutral600
            $0.isUserInteractionEnabled = false
        }
        
        startButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .action001
            config.baseForegroundColor = .neutralWhite
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 0, bottom: 18, trailing: 0)
            
            $0.configuration = config
            $0.setTitleWithTypography("포비와 함께 시작하기", style: .header16)
        }
    }
    
    private func layout() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(collectionView)
        addSubview(pageControl)
        addSubview(startButton)

        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // CollectionView (슬라이드)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(80)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(280)
        }

        // PageControl
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(collectionView.snp.bottom).offset(20)
        }

        // Start Button
        startButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(56)
        }
    }
}

// UICollectionViewDataSource

extension OnboardingCompleteView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slideData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingSlideCell.identifier,
            for: indexPath
        ) as? OnboardingSlideCell else {
            return UICollectionViewCell()
        }

        let character = slideData[indexPath.item]
        cell.configure(with: character)

        return cell
    }
}

// UICollectionViewDelegate

extension OnboardingCompleteView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cellWidth: CGFloat = 240
        let spacing: CGFloat = 10
        let pageWidth = cellWidth + spacing

        // 현재 페이지 계산 (반올림)
        let currentPage = Int(round(scrollView.contentOffset.x / pageWidth))
        pageControl.currentPage = min(max(currentPage, 0), slideData.count - 1)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellWidth: CGFloat = 240
        let spacing: CGFloat = 10
        let pageWidth = cellWidth + spacing

        // 현재 오프셋 기반으로 페이지 계산
        let currentOffset = scrollView.contentOffset.x
        var targetPage = round(currentOffset / pageWidth)

        // 빠른 스와이프 시 velocity 기반으로 페이지 이동
        if velocity.x > 0.3 {
            targetPage = ceil(currentOffset / pageWidth)
        } else if velocity.x < -0.3 {
            targetPage = floor(currentOffset / pageWidth)
        }

        // 페이지 범위 제한
        targetPage = max(0, min(targetPage, CGFloat(slideData.count - 1)))

        // 새 타겟 오프셋 설정
        targetContentOffset.pointee.x = targetPage * pageWidth
    }
}

// UICollectionViewDelegateFlowLayout

extension OnboardingCompleteView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 240
        let height: CGFloat = 280
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // 첫 번째 셀이 화면 중앙에서 시작하도록
        let collectionViewWidth = collectionView.bounds.width
        let cellWidth: CGFloat = 240
        let leftInset = (collectionViewWidth - cellWidth) / 2
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: leftInset)
    }
}

#Preview {
    OnboardingCompleteView()
}
