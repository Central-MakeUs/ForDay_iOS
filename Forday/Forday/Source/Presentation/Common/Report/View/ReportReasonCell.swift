//
//  ReportReasonCell.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import UIKit
import SnapKit
import Then

final class ReportReasonCell: UICollectionViewCell {

    static let identifier = "ReportReasonCell"

    // MARK: - UI Components

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let checkImageView = UIImageView()

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

    func configure(with reason: ReportReasonType, isSelected: Bool) {
        titleLabel.setTextWithTypography(reason.displayName, style: .body16)

        if isSelected {
            containerView.backgroundColor = .primary003
            containerView.layer.borderColor = UIColor.action001.cgColor
            containerView.layer.borderWidth = 1.5
            titleLabel.textColor = .neutral900
            checkImageView.isHidden = false
        } else {
            containerView.backgroundColor = .neutralWhite
            containerView.layer.borderColor = UIColor.stroke001.cgColor
            containerView.layer.borderWidth = 1
            titleLabel.textColor = .neutral800
            checkImageView.isHidden = true
        }
    }
}

// MARK: - Setup

extension ReportReasonCell {
    private func style() {
        containerView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
        }

        titleLabel.do {
            $0.textColor = .neutral800
        }

        checkImageView.do {
            $0.image = .Icon.checkCircle
            $0.tintColor = .action001
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }
    }

    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(checkImageView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(checkImageView.snp.leading).offset(-8)
        }

        checkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
}

#if DEBUG
#Preview("ReportReasonCell - Default") {
    let cell = ReportReasonCell()
    cell.configure(with: .spam, isSelected: false)
    cell.frame = CGRect(x: 0, y: 0, width: 300, height: 52)
    return cell
}

#Preview("ReportReasonCell - Selected") {
    let cell = ReportReasonCell()
    cell.configure(with: .hateSpeech, isSelected: true)
    cell.frame = CGRect(x: 0, y: 0, width: 300, height: 52)
    return cell
}
#endif
