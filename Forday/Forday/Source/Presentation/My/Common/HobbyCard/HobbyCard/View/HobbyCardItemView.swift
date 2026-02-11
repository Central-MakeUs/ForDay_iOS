//
//  HobbyCardItemView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class HobbyCardItemView: UIView {

    // MARK: - Properties

    private let imageView = UIImageView()
    private let textLabel = UILabel()
    private let textBackgroundView = UIView()

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

    func configure(with card: CompletedHobbyCard) {
        // TODO: Load image from URL when image loading is implemented
        imageView.image = UIImage(systemName: "photo.fill")
        imageView.tintColor = .systemGray3

        textLabel.text = card.content
    }
}

// MARK: - Setup

extension HobbyCardItemView {
    private func style() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .systemGray5
        }

        textBackgroundView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }

        textLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .white
            $0.numberOfLines = 0
        }
    }

    private func layout() {
        addSubview(imageView)
        addSubview(textBackgroundView)
        textBackgroundView.addSubview(textLabel)

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        textBackgroundView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(60)
        }

        textLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
