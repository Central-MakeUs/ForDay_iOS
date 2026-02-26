//
//  AppIntroPageCell.swift
//  Forday
//
//  Created by Subeen on 2/26/26.
//

import UIKit
import SnapKit
import Then

/// 앱 소개 페이지의 개별 셀
final class AppIntroPageCell: UICollectionViewCell {

    static let identifier = "AppIntroPageCell"

    // MARK: - UI Components

    private let imageView = UIImageView()

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

    func configure(with image: UIImage?) {
        imageView.image = image
    }
}

// MARK: - Setup

extension AppIntroPageCell {
    private func style() {
        contentView.backgroundColor = .bg004

        imageView.do {
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        contentView.addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
