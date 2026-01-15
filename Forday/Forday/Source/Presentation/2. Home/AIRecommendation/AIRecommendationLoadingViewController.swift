//
//  AIRecommendationLoadingViewController.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import UIKit
import SnapKit
import Then
import Lottie

class AIRecommendationLoadingViewController: UIViewController {
    
    // Properties
    
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let dotIndicator1 = UIView()
    private let dotIndicator2 = UIView()
    private let dotIndicator3 = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    // Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        startAnimation()
    }
}

// Setup

extension AIRecommendationLoadingViewController {
    private func style() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        containerView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 20
        }
        
        iconImageView.do {
            $0.image = UIImage(systemName: "sparkles")
            $0.tintColor = .systemOrange
            $0.contentMode = .scaleAspectFit
        }
        
        [dotIndicator1, dotIndicator2, dotIndicator3].forEach { dot in
            dot.do {
                $0.backgroundColor = .systemOrange
                $0.layer.cornerRadius = 4
            }
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
        view.addSubview(containerView)
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(dotIndicator1)
        containerView.addSubview(dotIndicator2)
        containerView.addSubview(dotIndicator3)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        
        // Container
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        
        // Icon
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        // Dots
        dotIndicator1.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview().offset(-20)
            $0.width.height.equalTo(8)
        }
        
        dotIndicator2.snp.makeConstraints {
            $0.centerY.equalTo(dotIndicator1)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(8)
        }
        
        dotIndicator3.snp.makeConstraints {
            $0.centerY.equalTo(dotIndicator1)
            $0.centerX.equalToSuperview().offset(20)
            $0.width.height.equalTo(8)
        }
        
        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dotIndicator1.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-40)
        }
    }
}

// Animation

extension AIRecommendationLoadingViewController {
    private func startAnimation() {
        // Dot 애니메이션
        animateDots()
    }
    
    private func animateDots() {
        let dots = [dotIndicator1, dotIndicator2, dotIndicator3]
        
        for (index, dot) in dots.enumerated() {
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.2,
                options: [.repeat, .autoreverse],
                animations: {
                    dot.alpha = 0.3
                }
            )
        }
    }
}

#Preview {
    AIRecommendationLoadingViewController()
}
