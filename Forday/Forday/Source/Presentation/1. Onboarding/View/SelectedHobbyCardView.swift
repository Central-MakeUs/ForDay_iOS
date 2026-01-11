//
//  SelectedHobbyCardView.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//

import UIKit
import SnapKit
import Then

class SelectedHobbyCardView: UIView {
    
    // Properties
    
    private let iconImageView = UIImageView()
    private let timeLabel = UILabel()
    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configuration
    
    func configure(iconName: String, time: String, title: String) {
        iconImageView.image = UIImage(systemName: iconName)
        timeLabel.text = time
        titleLabel.text = title
    }
}

// Setup

extension SelectedHobbyCardView {
    private func style() {
        backgroundColor = .bg001
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        
        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .systemOrange
        }
        
        timeLabel.do {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
        }
        
        titleLabel.do {
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = .label
        }
        
        checkmarkImageView.do {
            $0.image = UIImage(systemName: "checkmark")
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .secondaryLabel
        }
    }
    
    private func layout() {
        addSubview(iconImageView)
        addSubview(timeLabel)
        addSubview(titleLabel)
        addSubview(checkmarkImageView)
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(12)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(timeLabel)
            $0.top.equalTo(timeLabel.snp.bottom).offset(3)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        checkmarkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(10)  // 겹치지 않게
        }
    }
}

#Preview {
    SelectedHobbyCardView()
}
