//
//  LoginView.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import UIKit
import SnapKit
import Then

class LoginView: UIView {
    
    // Properties
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let snsDescriptionLabel = UILabel()
    let kakaoLoginButton = UIButton()
    let appleLoginButton = UIButton()
    
    private let orLabel = UILabel()
    let guestLoginButton = UIButton()
    
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

extension LoginView {
    private func style() {
        backgroundColor = .systemBackground
        
        logoImageView.do {
            $0.image = UIImage(systemName: "face.smiling.fill")  // 임시 아이콘
            $0.tintColor = .systemOrange
            $0.contentMode = .scaleAspectFit
            $0.layer.cornerRadius = 50
            $0.backgroundColor = UIColor(hex: "FFE6D1")
        }
        
        titleLabel.do {
            $0.text = "포데이에\n오신 것을 환영합니다!"
            $0.font = .systemFont(ofSize: 28, weight: .bold)
            $0.textColor = .label
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        subtitleLabel.do {
            $0.text = "당신만의 취미 루틴, AI가 추천해드립니다"
            $0.font = .systemFont(ofSize: 15, weight: .regular)
            $0.textColor = .systemOrange
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        snsDescriptionLabel.do {
            $0.text = "SNS로 가볍게 시작하기!"
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .label
            $0.textAlignment = .center
        }
        
        kakaoLoginButton.do {
            var config = UIButton.Configuration.filled()
            
            // 카카오 로고
            let kakaoImage = UIImage(systemName: "message.fill")  // 임시 아이콘
            config.image = kakaoImage
            config.imagePlacement = .leading
            config.imagePadding = 8
            
            config.title = "카카오톡으로 시작하기"
            config.baseBackgroundColor = UIColor(hex: "FEE500")  // 카카오 옐로우
            config.baseForegroundColor = UIColor(hex: "000000").withAlphaComponent(0.85)
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
            
            $0.configuration = config
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        }
        
        appleLoginButton.do {
            var config = UIButton.Configuration.filled()
            
            // Apple 로고
            let appleImage = UIImage(systemName: "apple.logo")
            config.image = appleImage
            config.imagePlacement = .leading
            config.imagePadding = 8
            
            config.title = "Apple로 시작하기"
            config.baseBackgroundColor = .label
            config.baseForegroundColor = .systemBackground
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
            
            $0.configuration = config
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        }
        
        orLabel.do {
            $0.text = "또는"
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
        }
        
        guestLoginButton.do {
            var config = UIButton.Configuration.plain()
            config.title = "게스트로 둘러보기"
            config.baseForegroundColor = .secondaryLabel
            
            $0.configuration = config
            $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            
            // 밑줄
            let attributedString = NSAttributedString(
                string: "게스트로 둘러보기",
                attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]
            )
            $0.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    private func layout() {
        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(snsDescriptionLabel)
        addSubview(kakaoLoginButton)
        addSubview(appleLoginButton)
        addSubview(orLabel)
        addSubview(guestLoginButton)
        
        // Logo
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide).offset(100)
            $0.width.height.equalTo(100)
        }
        
        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        
        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        
        // SNS Description
        snsDescriptionLabel.snp.makeConstraints {
            $0.bottom.equalTo(kakaoLoginButton.snp.top).offset(-24)
            $0.centerX.equalToSuperview()
        }
        
        // Kakao Button
        kakaoLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(appleLoginButton.snp.top).offset(-12)
            $0.height.equalTo(56)
        }
        
        // Apple Button
        appleLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(orLabel.snp.top).offset(-32)
            $0.height.equalTo(56)
        }
        
        // Or Label
        orLabel.snp.makeConstraints {
            $0.bottom.equalTo(guestLoginButton.snp.top).offset(-16)
            $0.centerX.equalToSuperview()
        }
        
        // Guest Button
        guestLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-40)
        }
    }
}

#Preview {
    LoginView()
}