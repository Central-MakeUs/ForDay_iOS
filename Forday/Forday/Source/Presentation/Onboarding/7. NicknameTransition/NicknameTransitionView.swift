//
//  NicknameTransitionView.swift
//  Forday
//
//  Created by Subeen on 1/28/26.
//

import UIKit
import SnapKit
import Then

class NicknameTransitionView: UIView {

    // Properties

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let checkmarkContainerView = UIView()
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
}

// Setup

extension NicknameTransitionView {
    private func style() {
        backgroundColor = .neutralWhite

        titleLabel.do {
            $0.text = "주신 정보 너무 감사해요!"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .label
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            $0.text = "해당 정보들로 포데이 AI 추천에 잘 사용할게요.\n뉴 포비님의 취미생활이 더욱 즐겁도록 함께해요."
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        checkmarkContainerView.do {
            $0.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
            $0.layer.cornerRadius = 80
        }

        checkmarkImageView.do {
            $0.image = UIImage(systemName: "checkmark")
            $0.tintColor = .systemOrange
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(checkmarkContainerView)
        checkmarkContainerView.addSubview(checkmarkImageView)

        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(200)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // Checkmark Container (Circle)
        checkmarkContainerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(80)
            $0.width.height.equalTo(160)
        }

        // Checkmark Icon
        checkmarkImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }
    }
}

#Preview {
    NicknameTransitionView()
}
