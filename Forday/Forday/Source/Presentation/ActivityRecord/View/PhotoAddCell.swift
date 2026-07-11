//
//  PhotoAddCell.swift
//  Forday
//
//  Created by Subeen on 6/14/26.
//

import UIKit
import SnapKit
import Then

/// 취미 사진 섹션의 사진 추가 버튼 셀
/// - Note: 52x52 크기, 카메라 아이콘 + "n/5" 카운터 표시
class PhotoAddCell: UICollectionViewCell {

    // MARK: - Constants

    static let maxPhotoCount = 5

    // MARK: - UI Components

    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let countLabel = UILabel()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension PhotoAddCell {
    private func style() {
        containerView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.clipsToBounds = true
        }

        iconImageView.do {
            $0.image = .Icon.camera
            $0.tintColor = .neutral400
            $0.contentMode = .scaleAspectFit
        }

        countLabel.do {
            $0.setTextWithTypography("0/5", style: .label10)
            $0.textColor = .neutral600
            $0.textAlignment = .center
        }
    }

    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(countLabel)

        containerView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            $0.width.height.equalTo(52)
        }

        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        countLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
}

// MARK: - Configure

extension PhotoAddCell {
    /// 현재 사진 개수 업데이트
    /// - Parameter count: 현재 선택된 사진 개수
    func configure(currentCount: Int) {
        countLabel.setTextWithTypography("\(currentCount)/\(PhotoAddCell.maxPhotoCount)", style: .label10)
    }
}
