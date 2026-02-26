//
//  ReportView.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import UIKit
import SnapKit
import Then

final class ReportView: UIView {

    // MARK: - UI Components

    private let navigationBar = UIView()
    let backButton = UIButton()
    private let titleLabel = UILabel()

    private let headerTitleLabel = UILabel()
    private let headerDescriptionLabel = UILabel()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private let bottomButtonContainer = UIView()
    let submitButton = UIButton()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func updateSubmitButtonState(isEnabled: Bool) {
        submitButton.isEnabled = isEnabled
        submitButton.backgroundColor = isEnabled ? .action001 : .action003
    }
}

// MARK: - Setup

extension ReportView {
    private func style() {
        backgroundColor = .neutralWhite

        // Navigation Bar
        navigationBar.do {
            $0.backgroundColor = .neutralWhite
        }

        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral900
        }

        titleLabel.do {
            $0.setTextWithTypography("신고하기", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        // Header Title
        headerTitleLabel.do {
            $0.setTextWithTypography("해당 게시글이나 유저에 어떤 문제가 있나요?", style: .header20)
            $0.textColor = .neutral900
        }

        // Header Description
        headerDescriptionLabel.do {
            $0.text = "회원님의 신고는 익명으로 처리됩니다.\n신고사유를 선택해주세요."
            $0.font = TypographyStyle.label14.font
            $0.textColor = .neutral800
            $0.numberOfLines = 0
        }

        // Collection View
        collectionView.do {
            $0.backgroundColor = .clear
            $0.register(ReportReasonCell.self, forCellWithReuseIdentifier: ReportReasonCell.identifier)
            $0.showsVerticalScrollIndicator = false
        }

        // Bottom Button Container
        bottomButtonContainer.do {
            $0.backgroundColor = .clear
        }

        // Submit Button
        submitButton.do {
            $0.setTitle("제출하기", for: .normal)
            $0.setTitleColor(.neutralWhite, for: .normal)
            $0.titleLabel?.font = TypographyStyle.header16.font
            $0.backgroundColor = .action003
            $0.layer.cornerRadius = 12
            $0.isEnabled = false
        }
    }

    private func layout() {
        addSubview(navigationBar)
        navigationBar.addSubview(backButton)
        navigationBar.addSubview(titleLabel)
        addSubview(headerTitleLabel)
        addSubview(headerDescriptionLabel)
        addSubview(collectionView)
        addSubview(bottomButtonContainer)
        bottomButtonContainer.addSubview(submitButton)

        // Navigation Bar
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        // Header Title
        headerTitleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // Header Description
        headerDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(headerTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // Collection View
        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerDescriptionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(bottomButtonContainer.snp.top)
        }

        // Bottom Button Container
        bottomButtonContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(88)
        }

        // Submit Button
        submitButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(56)
        }
    }
}

#if DEBUG
#Preview("ReportView") {
    ReportView()
}
#endif
