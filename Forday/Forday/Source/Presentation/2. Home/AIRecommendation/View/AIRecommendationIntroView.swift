//
//  AIRecommendationIntroView.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import SnapKit
import Then

class AIRecommendationIntroView: UIView {
    
    // Properties
    
    private let toastView = UIView()
    private let toastIconImageView = UIImageView()
    private let toastLabel = UILabel()
    
    private let recommendButton = UIButton()
    
    // Callbacks
    var onAIRecommendTapped: (() -> Void)?
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension AIRecommendationIntroView {
    private func style() {
        backgroundColor = .systemBackground
        
        // Toast
        toastView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 12
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 8
        }
        
        toastIconImageView.do {
            $0.image = UIImage(systemName: "sparkles")
            $0.tintColor = .systemOrange
            $0.contentMode = .scaleAspectFit
        }
        
        toastLabel.do {
            $0.text = "포데이 AI가 알맞은 취미활동을 추천해드려요"
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        
        // Button
        recommendButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "AI 추천받기"
            config.baseBackgroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0)
            config.baseForegroundColor = .label
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
            
            $0.configuration = config
        }
    }
    
    private func layout() {
        addSubview(toastView)
        addSubview(recommendButton)
        
        toastView.addSubview(toastIconImageView)
        toastView.addSubview(toastLabel)
        
        // Toast
        toastView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        toastIconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        toastLabel.snp.makeConstraints {
            $0.leading.equalTo(toastIconImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.bottom.equalToSuperview().inset(16)
        }
        
        // Button
        recommendButton.snp.makeConstraints {
            $0.top.equalTo(toastView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
        }
    }
    
    private func setupActions() {
        recommendButton.addTarget(
            self,
            action: #selector(recommendButtonTapped),
            for: .touchUpInside
        )
    }
    
    @objc private func recommendButtonTapped() {
        onAIRecommendTapped?()
    }
}

#Preview {
    AIRecommendationIntroView()
}
