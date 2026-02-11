//
//  HobbySelectionView.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//


import UIKit
import SnapKit
import Then

class HobbySelectionView: UIView {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // Custom input button
    let customInputButtonView = UIView()
    private let customInputIconView = UIImageView()
    private let customInputTitleLabel = UILabel()
    private let customInputCheckView = UIImageView()

    // MARK: - Properties

    private var collectionViewHeightConstraint: Constraint?

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

extension HobbySelectionView {
    private func style() {
        backgroundColor = .neutral50

        scrollView.do {
            $0.showsVerticalScrollIndicator = false
        }

        titleLabel.do {
            $0.setTextWithTypography("어떤 취미를 시작하고 싶으세요?", style: .header20)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            let fullText = "마음에 드는 취미를 1개 선택해주세요.\n취미슬롯은 1개 더 확장 가능해요!"
            let attributedString = NSMutableAttributedString(string: fullText)

            // 기본 스타일
            let fullRange = NSRange(location: 0, length: fullText.count)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.4
            attributedString.addAttributes([
                .foregroundColor: UIColor.neutral800,
                .paragraphStyle: paragraphStyle
            ], range: fullRange)

            // "1개" 강조 색상
            if let range = fullText.range(of: "1개") {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttribute(.foregroundColor, value: UIColor.secondary003, range: nsRange)
            }

            $0.attributedText = attributedString
            $0.applyTypography(.label14)
            $0.numberOfLines = 0
        }

        collectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.isScrollEnabled = false
            $0.register(HobbyCollectionViewCell.self, forCellWithReuseIdentifier: HobbyCollectionViewCell.identifier)
        }

        customInputButtonView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.clipsToBounds = true
        }

        customInputIconView.do {
            $0.image = .Icon.pencil
            $0.tintColor = .neutral800
            $0.contentMode = .scaleAspectFit
        }

        customInputTitleLabel.do {
            $0.setTextWithTypography("원하는 취미가 없으신가요?", style: .header14)
            $0.textColor = .neutral800
        }

        customInputCheckView.do {
            $0.image = .Icon.check
            $0.tintColor = .action001
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }
    }

    private func layout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(customInputButtonView)
        customInputButtonView.addSubview(customInputIconView)
        customInputButtonView.addSubview(customInputTitleLabel)
        customInputButtonView.addSubview(customInputCheckView)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-80)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            collectionViewHeightConstraint = $0.height.equalTo(0).constraint
        }

        customInputButtonView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-24)
        }

        customInputIconView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(customInputTitleLabel.snp.leading).offset(-10)
            $0.size.equalTo(20)
        }

        customInputTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        customInputCheckView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(customInputTitleLabel.snp.trailing).offset(10)
            $0.size.equalTo(16)
        }
    }
}

// MARK: - Public Methods

extension HobbySelectionView {
    func updateCollectionViewHeight() {
        layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeightConstraint?.update(offset: contentHeight)
        layoutIfNeeded()
    }

    func updateCustomInputButton(hobbyName: String) {
        customInputButtonView.layer.borderColor = UIColor.action001.cgColor
        customInputTitleLabel.setTextWithTypography(hobbyName, style: .header14)
        customInputTitleLabel.textColor = .neutral800
        customInputCheckView.isHidden = false
    }

    func resetCustomInputButton() {
        customInputButtonView.layer.borderColor = UIColor.stroke001.cgColor
        customInputTitleLabel.setTextWithTypography("원하는 취미가 없으신가요?", style: .header14)
        customInputTitleLabel.textColor = .neutral800
        customInputCheckView.isHidden = true
    }
}
