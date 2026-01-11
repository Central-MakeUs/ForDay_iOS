//
//  FrequencyButtonCell.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import UIKit
import SnapKit
import Then

class FrequencyButtonCell: UICollectionViewCell {
    
    static let identifier = "FrequencyButtonCell"
    
    // Properties
    
    private let containerView = UIView()
    private let numberLabel = UILabel()
    
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
    
    func configure(count: Int, isSelected: Bool) {
        numberLabel.text = "\(count)"
        
        // 선택 상태에 따른 스타일 변경
        if isSelected {
            containerView.backgroundColor = .primary003
            containerView.layer.borderColor = UIColor.primary001.cgColor
            containerView.layer.borderWidth = 1
            numberLabel.textColor = .neutralBlack
        } else {
            containerView.backgroundColor = .neutralWhite
            containerView.layer.borderColor = UIColor.stroke001.cgColor
            containerView.layer.borderWidth = 1
            numberLabel.textColor = .neutralBlack
        }
    }
}

// Setup

extension FrequencyButtonCell {
    private func style() {
        containerView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
        }
        
        numberLabel.do {
            $0.font = .systemFont(ofSize: 20, weight: .semibold)
            $0.textColor = .neutralBlack
            $0.textAlignment = .center
        }
    }
    
    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(numberLabel)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        numberLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
