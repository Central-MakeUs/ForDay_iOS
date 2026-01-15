//
//  ToastView.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import SnapKit
import Then

class ToastView: UIView {
    
    // Properties
    
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let messageLabel = UILabel()
    
    // Initialization
    
    init(message: String) {
        super.init(frame: .zero)
        messageLabel.text = message
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension ToastView {
    private func style() {
        backgroundColor = .clear
        
        containerView.do {
            $0.backgroundColor = .bg001
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }
        
        iconImageView.do {
            $0.image = .Ai.default
            $0.contentMode = .scaleAspectFit
        }
        
        messageLabel.do {
            $0.applyTypography(.body14)
            $0.textColor = .neutral800
            $0.numberOfLines = 1
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.applyGradientBorder(DesignGradient.gradient002, lineWidth: 1, cornerRadius: 20)
    }
    
    private func layout() {
        addSubview(containerView)
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(messageLabel)
        
        // Container
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // Icon
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(22)
        }
        
        // Message
        messageLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
}

// Public Methods

extension ToastView {
    func show(in view: UIView, bottomOffset: CGFloat = 0) {
        view.addSubview(self)
        
        self.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(bottomOffset)
        }
        
        // 페이드 인 애니메이션
        alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    func hide(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
}

#Preview {
    ToastView(message: "포데이 AI가 알맞은 취미활동을 추천해드려요")
}
