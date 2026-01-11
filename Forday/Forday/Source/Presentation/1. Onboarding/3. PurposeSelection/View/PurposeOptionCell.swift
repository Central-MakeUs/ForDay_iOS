//
//  PurposeOptionCell.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import UIKit
import SnapKit
import Then

class PurposeOptionCell: UICollectionViewCell {
    
    static let identifier = "PurposeOptionCell"
    
    // Properties
    
    private let containerView = UIView()
    private let checkboxImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
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
    
    func configure(with purpose: PurposeModel, isSelected: Bool) {
        titleLabel.text = purpose.title
        subtitleLabel.text = purpose.subtitle
        
        // 선택 상태에 따른 스타일 변경
        if isSelected {
            containerView.backgroundColor = .systemBackground
            containerView.layer.borderColor = UIColor.systemOrange.cgColor
            containerView.layer.borderWidth = 2
            checkboxImageView.image = UIImage(systemName: "checkmark.square.fill")
            checkboxImageView.tintColor = .systemOrange
        } else {
            containerView.backgroundColor = .systemBackground
            containerView.layer.borderColor = UIColor.systemGray5.cgColor
            containerView.layer.borderWidth = 1
            checkboxImageView.image = UIImage(systemName: "square")
            checkboxImageView.tintColor = .systemGray4
        }
    }
}

// Setup

extension PurposeOptionCell {
    private func style() {
        containerView.do {
            $0.backgroundColor = .systemBackground
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray5.cgColor
        }
        
        checkboxImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .systemGray4
            $0.image = UIImage(systemName: "square")
        }
        
        titleLabel.do {
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        
        subtitleLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 0
        }
    }
    
    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(checkboxImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkboxImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(checkboxImageView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.lessThanOrEqualToSuperview().offset(-16)  // 높이 자동 조절
        }
    }
}