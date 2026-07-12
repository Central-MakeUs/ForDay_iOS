//
//  StickerCell.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import SnapKit
import Then

class StickerCell: UICollectionViewCell {
    
    // Properties
    
    private let containerView = UIView()
    private let stickerImageView = UIImageView()
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup
    
    private func style() {
        containerView.do {
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
        }
        
        stickerImageView.do {
            $0.contentMode = .scaleAspectFit
        }
    }
    
    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(stickerImageView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stickerImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            // 셀 크기의 62.5% (기존 64셀에서 40이었으므로 비율 유지)
            $0.width.height.equalToSuperview().multipliedBy(0.625)
        }
    }
    
    // Configure
    
    func configure(with sticker: Sticker, isSelected: Bool) {
        stickerImageView.image = sticker.image

        containerView.layer.borderColor = isSelected ? UIColor.action001.cgColor : UIColor.stroke001.cgColor
    }
}
