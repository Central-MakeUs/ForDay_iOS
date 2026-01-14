//
//  AIRecommendationLoadingView.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import SnapKit
import Then
import Lottie

class AIRecommendationLoadingView: UIView {
    
    // Properties
    
    private let animationView = LottieAnimationView(name: "lottie/loading")
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        startAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension AIRecommendationLoadingView {
    private func style() {
        backgroundColor = .systemBackground
        
        animationView.do {
            $0.loopMode = .loop
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.text = "유지2의 취미를 분석 중"
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = .label
            $0.textAlignment = .center
        }
        
        subtitleLabel.do {
            $0.text = "독서 AI 활동을 생성 중이에요."
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
        }
    }
    
    private func layout() {
        addSubview(animationView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        // Animation
        animationView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        
        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(animationView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func startAnimation() {
        animationView.play()
    }
}