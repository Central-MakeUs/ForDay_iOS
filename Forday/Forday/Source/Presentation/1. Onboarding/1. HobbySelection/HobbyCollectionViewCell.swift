//
//  HobbyCollectionViewCell.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//


import UIKit
import SnapKit
import Then

class HobbyCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HobbyCollectionViewCell"
    
    // MARK: - Properties
    
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(with hobby: HobbyCard, isSelected: Bool) {
        backgroundImageView.image = hobby.imageAsset.image
        titleLabel.text = hobby.name
        subtitleLabel.text = hobby.description
        checkmarkImageView.isHidden = !isSelected
    }
}

// MARK: - Setup

extension HobbyCollectionViewCell {
    private func style() {
        contentView.do {
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
        
        backgroundImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .systemGray5
        }

        titleLabel.do {
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = .white
            $0.numberOfLines = 1
        }
        
        subtitleLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .white
            $0.numberOfLines = 2
        }
        
        checkmarkImageView.do {
            $0.image = UIImage(systemName: "checkmark.circle.fill")
            $0.tintColor = .white
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }
    }
    
    private func layout() {
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(checkmarkImageView)
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkmarkImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.width.height.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
