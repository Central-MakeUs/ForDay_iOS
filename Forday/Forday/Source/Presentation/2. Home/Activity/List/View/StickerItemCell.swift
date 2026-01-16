//
//  StickerItemCell.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import UIKit
import SnapKit
import Then

class StickerItemCell: UICollectionViewCell {
    
    static let identifier = "StickerItemCell"
    
    // Properties
    
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
}

// Setup

extension StickerItemCell {
    private func style() {
        contentView.do {
            $0.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
            $0.layer.cornerRadius = 8
        }
        
        stickerImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .systemOrange
        }
    }
    
    private func layout() {
        contentView.addSubview(stickerImageView)
        
        stickerImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(40)
        }
    }
}

// Configure

extension StickerItemCell {
    func configure(with sticker: ActivitySticker) {
        // TODO: 실제 스티커 이미지 로드
        // 임시로 SF Symbol 사용
        stickerImageView.image = UIImage(systemName: "face.smiling")
    }
}
