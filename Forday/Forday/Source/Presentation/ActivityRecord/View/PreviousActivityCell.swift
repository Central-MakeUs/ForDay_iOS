//
//  PreviousActivityCell.swift
//  Forday
//
//  Created by Subeen on 6/14/26.
//

import UIKit
import SnapKit
import Then

/// 이전 활동리스트 바텀시트의 활동 아이템 셀
/// - Note: 활동명 + 아이콘 + 횟수 + 체크박스 표시
final class PreviousActivityCell: UICollectionViewCell {

    // MARK: - UI Components

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let countContainerView = UIView()
    private let countIconImageView = UIImageView()
    private let countLabel = UILabel()
    private let checkboxImageView = UIImageView()

    // MARK: - Properties

    private var isSelectedState: Bool = false

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        countLabel.text = nil
        updateSelection(false)
    }
}

// MARK: - Setup

extension PreviousActivityCell {
    private func style() {
        containerView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.clipsToBounds = true
        }

        titleLabel.do {
            $0.font = TypographyStyle.body14.font
            $0.textColor = .neutral900
            $0.numberOfLines = 1
        }

        countIconImageView.do {
            $0.image = .Icon.my
            $0.tintColor = .neutral500
            $0.contentMode = .scaleAspectFit
        }

        countLabel.do {
            $0.font = TypographyStyle.label12.font
            $0.textColor = .neutral500
        }

        checkboxImageView.do {
            $0.image = .Onoff.checkboxFalse
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(countContainerView)
        countContainerView.addSubview(countIconImageView)
        countContainerView.addSubview(countLabel)
        containerView.addSubview(checkboxImageView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }

        countContainerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }

        countIconImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        countLabel.snp.makeConstraints {
            $0.leading.equalTo(countIconImageView.snp.trailing).offset(2)
            $0.trailing.centerY.equalToSuperview()
        }

        checkboxImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(20)
            $0.leading.greaterThanOrEqualTo(countContainerView.snp.trailing).offset(8)
        }
    }
}

// MARK: - Configure

extension PreviousActivityCell {
    /// 셀 구성
    /// - Parameters:
    ///   - activityName: 활동명
    ///   - count: 기록 횟수
    ///   - isSelected: 선택 상태
    func configure(activityName: String, count: Int, isSelected: Bool) {
        titleLabel.text = activityName
        countLabel.text = "\(count)"
        updateSelection(isSelected)
    }

    /// 선택 상태 업데이트
    func updateSelection(_ selected: Bool) {
        isSelectedState = selected

        if selected {
            containerView.layer.borderColor = UIColor.action001.cgColor
            checkboxImageView.image = .Onoff.checkboxTrue
        } else {
            containerView.layer.borderColor = UIColor.stroke001.cgColor
            checkboxImageView.image = .Onoff.checkboxFalse
        }
    }
}
