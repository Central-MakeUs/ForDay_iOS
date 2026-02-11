//
//  SelectedHobbyCardView.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//

import UIKit
import SnapKit
import Then

class SelectedHobbyCardView: UIView {

    // Properties

    private let iconImageView = UIImageView()
    private let infoStackView = UIStackView()
    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()

    private let contentStackView = UIStackView()

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

    func configure(icon: UIImage?, title: String) {
        iconImageView.image = icon
        titleLabel.text = title

        // 정보가 없으면 타이틀만 표시 (centerY)
        contentStackView.axis = .vertical
        infoStackView.isHidden = true
        updateCheckmarkColor(isSelected: false)
    }

    func updateInfo(time: String? = nil, frequency: String? = nil, purpose: String? = nil) {
        // 기존 infoStackView의 arrangedSubviews 제거
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var infoItems: [String] = []

        if let time = time, !time.isEmpty {
            infoItems.append(time)
        }

        if let purpose = purpose, !purpose.isEmpty {
            infoItems.append(purpose)
        }

        if let frequency = frequency, !frequency.isEmpty {
            infoItems.append(frequency)
        }

        // 정보가 있으면 infoStackView 표시
        if !infoItems.isEmpty {
            infoStackView.isHidden = false

            for (index, item) in infoItems.enumerated() {
                let label = UILabel()
                label.setTextWithTypography(item, style: .label10)
                label.textColor = .neutral600
                infoStackView.addArrangedSubview(label)

                // 마지막 아이템이 아니면 점(•) 추가
                if index < infoItems.count - 1 {
                    let dotLabel = UILabel()
                    dotLabel.setTextWithTypography("•", style: .label10)
                    dotLabel.textColor = .neutral600
                    infoStackView.addArrangedSubview(dotLabel)
                }
            }
        } else {
            infoStackView.isHidden = true
        }

        updateCheckmarkColor(isSelected: false)
    }

    func setSelected(_ isSelected: Bool) {
        updateCheckmarkColor(isSelected: isSelected)
    }

    private func updateCheckmarkColor(isSelected: Bool) {
        // 셀을 선택하기 전: .neutral200, 선택 후: .action001
        checkmarkImageView.tintColor = isSelected ? .action001 : .neutral200
    }
}

// Setup

extension SelectedHobbyCardView {
    private func style() {
        backgroundColor = .bg001
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 12

        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .systemOrange
        }

        infoStackView.do {
            $0.axis = .horizontal
            $0.spacing = 3
            $0.alignment = .center
            $0.isHidden = true
        }

        titleLabel.do {
            $0.applyTypography(.body16)
            $0.textColor = .neutral800
        }

        checkmarkImageView.do {
            $0.image = .Icon.check
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .neutral200
        }

        contentStackView.do {
            $0.axis = .vertical
            $0.spacing = 3
            $0.alignment = .leading
        }
    }

    private func layout() {
        addSubview(iconImageView)
        addSubview(contentStackView)
        addSubview(checkmarkImageView)

        contentStackView.addArrangedSubview(infoStackView)
        contentStackView.addArrangedSubview(titleLabel)

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        contentStackView.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().offset(12)
            $0.bottom.lessThanOrEqualToSuperview().offset(-12)
        }

        checkmarkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
            $0.leading.greaterThanOrEqualTo(contentStackView.snp.trailing).offset(10)
        }
    }
}

#Preview {
    let view = SelectedHobbyCardView()
    view.configure(icon: UIImage(systemName: "book.fill"), title: "독서")
    view.updateInfo(time: "30분", frequency: "주 2회", purpose: nil)
    return view
}
