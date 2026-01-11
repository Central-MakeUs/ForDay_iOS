//
//  PeriodOptionCell.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//


import UIKit
import SnapKit
import Then

class PeriodOptionCell: UICollectionViewCell {
    
    static let identifier = "PeriodOptionCell"
    
    // Properties
    
    private let containerView = UIView()
    private let iconView = UIView()
    private let iconLabel = UILabel()
    
    private let titleView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
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

    func configure(with period: PeriodModel, isSelected: Bool) {
        titleLabel.text = period.title
        subtitleLabel.text = period.subtitle
        
        // 아이콘 설정 (Enum 활용)
        switch period.type {
        case .flexible:
            iconLabel.text = "∞"
        case .fixed:
            iconLabel.text = "😊"
        }
        
        // 선택 상태에 따른 스타일 변경
        if isSelected {
            containerView.backgroundColor = .systemBackground
            containerView.layer.borderColor = UIColor.systemOrange.cgColor
            containerView.layer.borderWidth = 2
            checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
            checkmarkImageView.tintColor = .systemOrange
        } else {
            containerView.backgroundColor = .systemBackground
            containerView.layer.borderColor = UIColor.systemGray5.cgColor
            containerView.layer.borderWidth = 1
            checkmarkImageView.image = UIImage(systemName: "circle")
            checkmarkImageView.tintColor = .systemGray4
        }
    }
}

// Setup

extension PeriodOptionCell {
    private func style() {
        containerView.do {
            $0.backgroundColor = .systemBackground
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray5.cgColor
        }
        
        iconView.do {
            $0.backgroundColor = UIColor(hex: "FFF4E6")
            $0.layer.cornerRadius = 26  // 52 / 2
        }
        
        iconLabel.do {
            $0.font = .systemFont(ofSize: 28)
            $0.textAlignment = .center
        }
        
        titleLabel.do {
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        
        subtitleLabel.do {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 0
        }
        
        checkmarkImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .systemGray4
        }
    }
    
    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        iconView.addSubview(iconLabel)
        
        // StackView 생성
        let titleStackView = UIStackView()
        titleStackView.axis = .vertical
        titleStackView.spacing = 4
        titleStackView.alignment = .leading
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subtitleLabel)
        
        containerView.addSubview(titleStackView)
        containerView.addSubview(checkmarkImageView)
        
        // Container
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // Icon
        iconView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().offset(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
            $0.width.height.equalTo(52)
        }
        
        iconLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        // TitleStackView
        titleStackView.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(checkmarkImageView.snp.leading).offset(-8)
            $0.top.greaterThanOrEqualToSuperview().offset(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        // Checkmark
        checkmarkImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(24)
        }
    }
}

#Preview("선택 안 됨") {
    let cell = PeriodOptionCell()
    cell.configure(
        with: PeriodModel(
            id: "1",
            title: "기간 미지정 (자율 모드)",
            subtitle: "정해두지 않고, 흐름대로",
            type: .flexible
        ),
        isSelected: false
    )
    
    let container = UIView()
    container.backgroundColor = .systemGray6
    container.addSubview(cell)
    
    // SnapKit으로 정가운데 + 크기 지정
    cell.snp.makeConstraints {
        $0.center.equalToSuperview()
        $0.leading.trailing.equalToSuperview().inset(20)
        $0.height.equalTo(160)
    }
    
    return container
}
