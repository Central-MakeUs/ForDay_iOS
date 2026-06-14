//
//  PhotoCell.swift
//  Forday
//
//  Created by Subeen on 6/14/26.
//

import UIKit
import SnapKit
import Then

/// 취미 사진 섹션의 사진 셀
/// - Note: 52x52 크기의 사진과 오른쪽 상단 삭제 버튼으로 구성
class PhotoCell: UICollectionViewCell {

    // MARK: - Properties

    /// 삭제 버튼 탭 시 호출되는 클로저
    var onDeleteTapped: (() -> Void)?

    // MARK: - UI Components

    private let imageView = UIImageView()
    private let deleteButton = UIButton()

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

extension PhotoCell {
    private func style() {
        contentView.clipsToBounds = false

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.clipsToBounds = true
        }

        deleteButton.do {
            $0.setImage(.Icon.imageDelete, for: .normal)
            $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        }
    }

    private func layout() {
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)

        imageView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            $0.width.height.equalTo(52)
        }

        deleteButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.top).offset(-4)
            $0.trailing.equalTo(imageView.snp.trailing).offset(4)
            $0.width.height.equalTo(16)
        }
    }

    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }
}

// MARK: - Configure

extension PhotoCell {
    func configure(with image: UIImage) {
        imageView.image = image
    }
}
