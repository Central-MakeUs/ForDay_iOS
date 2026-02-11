//
//  StoriesSearchBar.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import UIKit
import SnapKit
import Then

final class StoriesSearchBar: UIView {

    // MARK: - UI Components

    private let containerView = UIView()
    private let searchIconImageView = UIImageView()
    private let placeholderLabel = UILabel()

    // MARK: - Properties

    var onTap: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        onTap?()
    }
}

// MARK: - Setup

extension StoriesSearchBar {
    private func style() {
        backgroundColor = .systemBackground

        containerView.do {
            $0.backgroundColor = .neutral50
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }

        searchIconImageView.do {
            $0.image = UIImage(systemName: "magnifyingglass")
            $0.tintColor = .neutral400
            $0.contentMode = .scaleAspectFit
        }

        placeholderLabel.do {
            $0.setTextWithTypography("소식 검색", style: .body16)
            $0.textColor = .neutral400
        }
    }

    private func layout() {
        addSubview(containerView)
        containerView.addSubview(searchIconImageView)
        containerView.addSubview(placeholderLabel)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(48)
        }

        searchIconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        placeholderLabel.snp.makeConstraints {
            $0.leading.equalTo(searchIconImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }
}
