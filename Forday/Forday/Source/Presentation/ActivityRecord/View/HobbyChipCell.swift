//
//  HobbyChipCell.swift
//  Forday
//
//  Created by Subeen on 3/26/26.
//

import UIKit
import SnapKit
import Then

class HobbyChipCell: UICollectionViewCell {

    // Properties

    private let titleLabel = UILabel()

    // Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let labelSize = titleLabel.intrinsicContentSize
        // 좌우 패딩 12 * 2 = 24, 상하 패딩 6 * 2 = 12
        return CGSize(width: labelSize.width + 24, height: 32)
    }

    // Setup

    private func style() {
        contentView.do {
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.clipsToBounds = true
        }

        titleLabel.do {
            $0.setTextWithTypography("", style: .body14)
            $0.textAlignment = .center
            $0.numberOfLines = 1
        }
    }

    private func layout() {
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        // 텍스트가 잘리지 않도록 우선순위 설정
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    // Configure

    func configure(with hobbyChip: HobbyChip, isSelected: Bool) {
        titleLabel.text = hobbyChip.hobbyName

        // 상태에 따른 스타일 적용
        if hobbyChip.todayRecorded {
            // 비활성화 (이미 기록한 취미)
            contentView.backgroundColor = .neutral100
            contentView.layer.borderColor = UIColor.neutral100.cgColor
            titleLabel.textColor = .neutral500
        } else if isSelected {
            // 선택된 상태
            contentView.backgroundColor = .action001
            contentView.layer.borderColor = UIColor.action001.cgColor
            titleLabel.textColor = .neutralWhite
        } else {
            // 기본 상태
            contentView.backgroundColor = .neutralWhite
            contentView.layer.borderColor = UIColor.stroke001.cgColor
            titleLabel.textColor = .neutral800
        }
    }
}
