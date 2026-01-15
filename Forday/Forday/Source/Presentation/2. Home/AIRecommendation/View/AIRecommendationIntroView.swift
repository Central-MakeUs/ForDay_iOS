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
    
    private let aiImageView = UIImageView()
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
        backgroundColor = .neutralWhite
        
        aiImageView.do {
            $0.image = .Ai.default
            $0.contentMode = .scaleAspectFit
        }
        
        // Button
        recommendButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .primary003
            config.baseForegroundColor = .action001
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 60, bottom: 12, trailing: 60)
            
            $0.configuration = config
            $0.setTitleWithTypography("AI 추천받기", style: .header14)
        }
    }
    
    private func layout() {
        addSubview(aiImageView)
        addSubview(recommendButton)
        
        aiImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
        }
        
        // Button
        recommendButton.snp.makeConstraints {
            $0.top.equalTo(aiImageView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().offset(-60)
//            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
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
