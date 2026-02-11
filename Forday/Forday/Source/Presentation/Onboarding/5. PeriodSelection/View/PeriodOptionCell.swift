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
    private let checkboxImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let recommendLabel = UILabel()

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
        titleLabel.setTextWithTypography(period.title, style: .header16)
        subtitleLabel.setTextWithTypography(period.subtitle, style: .label12)

        // 추천 라벨: fixed(66일) 타입만 표시
        recommendLabel.isHidden = period.type != .fixed

        // 선택 상태에 따른 스타일 변경
        if isSelected {
            containerView.backgroundColor = .bg004
            containerView.layer.borderColor = UIColor.primary001.cgColor
            containerView.layer.borderWidth = 1
            checkboxImageView.image = .Onoff.checkboxTrue
        } else {
            containerView.backgroundColor = .bg001
            containerView.layer.borderColor = UIColor.stroke001.cgColor
            containerView.layer.borderWidth = 1
            checkboxImageView.image = .Onoff.checkboxFalse
        }
    }
}

// Setup

extension PeriodOptionCell {
    private func style() {
        containerView.do {
            $0.backgroundColor = .bg001
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
        }

        checkboxImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.image = .Onoff.checkboxFalse
        }

        titleLabel.do {
            $0.applyTypography(.header16)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            $0.applyTypography(.label12)
            $0.textColor = .neutral600
            $0.numberOfLines = 0
        }

        recommendLabel.do {
            $0.setTextWithTypography("추천", style: .body12)
            $0.textColor = .action001
            $0.isHidden = true
        }
    }

    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(checkboxImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(recommendLabel)

        // Container
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Checkbox (왼쪽)
        checkboxImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(12)
            $0.width.height.equalTo(24)
        }

        // 추천 라벨 (오른쪽 상단)
        recommendLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // Title
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkboxImageView.snp.leading)
            $0.top.equalTo(checkboxImageView.snp.bottom).offset(8)
        }

        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkboxImageView.snp.leading)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
//            $0.bottom.equalToSuperview().offset(-36)
        }
    }
}

#if DEBUG
#Preview("선택 안 됨 - 자율") {
    let cell = PeriodOptionCell()
    cell.configure(
        with: PeriodModel(id: "1", type: .flexible),
        isSelected: false
    )

    let container = UIView()
    container.backgroundColor = .bg002
    container.addSubview(cell)

    cell.snp.makeConstraints {
        $0.center.equalToSuperview()
        $0.leading.trailing.equalToSuperview().inset(20)
    }

    return container
}

#Preview("선택됨 - 추천") {
    let cell = PeriodOptionCell()
    cell.configure(
        with: PeriodModel(id: "2", type: .fixed),
        isSelected: true
    )

    let container = UIView()
    container.backgroundColor = .bg002
    container.addSubview(cell)

    cell.snp.makeConstraints {
        $0.center.equalToSuperview()
        $0.leading.trailing.equalToSuperview().inset(20)
    }

    return container
}
#endif
