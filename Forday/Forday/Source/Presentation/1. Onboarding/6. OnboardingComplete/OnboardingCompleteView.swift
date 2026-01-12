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
    let pageControl = UIPageControl()
    let startButton = UIButton()
    
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
        backgroundColor = .systemBackground
        
        titleLabel.do {
            $0.text = "포데이를 함께 할 포비들이에요!"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .label
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        subtitleLabel.do {
            $0.text = "취미 스티커 콜렉션을 꾸며요 채워보세요.\n뿌듯하실걸요?"
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        pageControl.do {
            $0.numberOfPages = 3
            $0.currentPage = 1
            $0.pageIndicatorTintColor = .systemGray4
            $0.currentPageIndicatorTintColor = .systemOrange
            $0.isUserInteractionEnabled = false
        }
        
        startButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "포비와 함께 시작하기"
            config.baseBackgroundColor = .systemOrange
            config.baseForegroundColor = .white
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 0, bottom: 18, trailing: 0)
            
            $0.configuration = config
        }
    }
    
    private func layout() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(pageControl)
        addSubview(startButton)
        
        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // PageControl (중간)
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        // Start Button
        startButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(56)
        }
    }
}

#Preview {
    OnboardingCompleteView()
}