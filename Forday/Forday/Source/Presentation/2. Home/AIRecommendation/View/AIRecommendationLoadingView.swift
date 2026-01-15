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
    
    private let aiImageView = UIImageView()
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
        backgroundColor = .neutralWhite
        
        aiImageView.do {
            $0.image = .Ai.default
            $0.contentMode = .scaleAspectFit
        }
        
        animationView.do {
            $0.loopMode = .loop
            $0.contentMode = .scaleAspectFit
        }
        
        // TODO: nickname 반영
        titleLabel.do {
            $0.setTextWithTypography("유지2의 취미를 분석 중", style: .header20)
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }
        
        subtitleLabel.do {
            $0.setTextWithTypography("독서 AI 활동을 생성 중이에요.", style: .label14)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }
    }
    
    private func layout() {
        addSubview(aiImageView)
        addSubview(animationView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        aiImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(42)
        }
        
        // Animation
        animationView.snp.makeConstraints {
            $0.top.equalTo(aiImageView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
        }
        
        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(animationView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func startAnimation() {
        animationView.play()
    }
}

#Preview {
    AIRecommendationLoadingView()
}
