//
//  HobbyChipCollectionViewCell.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//

import UIKit
import SnapKit
import Then

class HobbyChipCollectionViewCell: UICollectionViewCell {

    static let identifier = "HobbyChipCollectionViewCell"

    // MARK: - UI Components

    private let titleLabel = UILabel()

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

    func configure(with hobbyName: String, isSelected: Bool) {
        titleLabel.text = hobbyName

        if isSelected {
            contentView.backgroundColor = .action001
            titleLabel.textColor = .neutralWhite
            contentView.layer.borderWidth = 0
        } else {
            contentView.backgroundColor = .neutralWhite
            titleLabel.textColor = .neutral800
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.stroke001.cgColor
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}

// MARK: - Setup

extension HobbyChipCollectionViewCell {
    private func style() {
        contentView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 18
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.clipsToBounds = true
        }

        titleLabel.do {
            $0.applyTypography(.body14)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }
    }

    private func layout() {
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.bottom.equalToSuperview().offset(-9)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }
    }
}
