//
//  HobbyAddChipCell.swift
//  Forday
//
//  Created by Subeen on 6/14/26.
//

import UIKit
import SnapKit
import Then

/// 활동 추가 버튼 셀 (+ 아이콘만 있는 칩)
/// - Note: 32x32 크기, 원형 버튼
class HobbyAddChipCell: UICollectionViewCell {

    // MARK: - UI Components

    private let containerView = UIView()
    private let iconImageView = UIImageView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Size Calculation

    static let cellSize = CGSize(width: 32, height: 32)
}

// MARK: - Setup

extension HobbyAddChipCell {
    private func style() {
        containerView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.clipsToBounds = true
        }

        iconImageView.do {
            $0.image = .Icon.plus
            $0.tintColor = .neutral800
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)

        containerView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
}
