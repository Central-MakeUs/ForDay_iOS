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
    let closeButton = UIButton()
    private let titleLabel = UILabel()
    let submitButton = UIButton()

    private let descriptionLabel = UILabel()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

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
        submitButton.setTitleColor(isEnabled ? .action001 : .neutral400, for: .normal)
    }
}

// MARK: - Setup

extension ReportView {
    private func style() {
        backgroundColor = .neutral50

        // Navigation Bar
        navigationBar.do {
            $0.backgroundColor = .neutral50
        }

        closeButton.do {
            $0.setImage(.Icon.xmark, for: .normal)
            $0.tintColor = .neutral900
        }

        titleLabel.do {
            $0.setTextWithTypography("신고하기", style: .header18)
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }

        submitButton.do {
            $0.setTitle("완료", for: .normal)
            $0.setTitleColor(.neutral400, for: .normal)
            $0.titleLabel?.font = TypographyStyle.header16.font
            $0.isEnabled = false
        }

        // Description
        descriptionLabel.do {
            $0.setTextWithTypography("신고 사유를 선택해 주세요.", style: .body14)
            $0.textColor = .neutral600
        }

        // Collection View
        collectionView.do {
            $0.backgroundColor = .clear
            $0.register(ReportReasonCell.self, forCellWithReuseIdentifier: ReportReasonCell.identifier)
            $0.showsVerticalScrollIndicator = false
        }
    }

    private func layout() {
        addSubview(navigationBar)
        navigationBar.addSubview(closeButton)
        navigationBar.addSubview(titleLabel)
        navigationBar.addSubview(submitButton)
        addSubview(descriptionLabel)
        addSubview(collectionView)

        // Navigation Bar
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        submitButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }

        // Description
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        // Collection View
        collectionView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}

#if DEBUG
#Preview {
    ReportView()
}
#endif
