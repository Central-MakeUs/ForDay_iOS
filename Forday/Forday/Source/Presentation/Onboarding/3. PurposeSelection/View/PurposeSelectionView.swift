//
//  PurposeSelectionView.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import UIKit
import SnapKit
import Then

class PurposeSelectionView: UIView {

    // Properties

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let selectedHobbyCard = SelectedHobbyCardView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // Custom Input Button (icon layout)
    let customInputButtonView = UIView()
    private let customInputIconView = UIImageView()
    private let customInputTitleLabel = UILabel()
    private let customInputCheckView = UIImageView()

    // Properties
    private var collectionViewHeightConstraint: Constraint?

    // Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    // Configure

    func configureHobbyCard(icon: UIImage?, title: String, time: String?) {
        selectedHobbyCard.configure(icon: icon, title: title)
        if let time = time {
            selectedHobbyCard.updateInfo(time: time)
        }
        configureSubtitle(hobbyName: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension PurposeSelectionView {
    private func style() {
        backgroundColor = .neutral50

        scrollView.do {
            $0.showsVerticalScrollIndicator = false
        }

        titleLabel.do {
            $0.text = "어떤 목적으로 시작하나요?"
            $0.applyTypography(.header20)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            $0.numberOfLines = 0
        }

        collectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false  // 외부 ScrollView 사용
            $0.register(PurposeOptionCell.self, forCellWithReuseIdentifier: PurposeOptionCell.identifier)
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
            $0.setTextWithTypography("원하는 목적이 없으신가요?", style: .header14)
            $0.textColor = .neutral800
        }

        customInputCheckView.do {
            $0.image = .Icon.check
            $0.tintColor = .action001
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }
    }

    private func configureSubtitle(hobbyName: String) {
        let suffix = "를 통해 얻고 싶은 것을 선택해주세요.\n목적이 명확하면 동기부여가 더 쉬워져요!"
        let fullText = hobbyName + suffix

        let attributed = NSMutableAttributedString(string: fullText)

        let fullRange = NSRange(location: 0, length: fullText.utf16.count)
        attributed.addAttributes(TypographyStyle.label14.attributes, range: fullRange)
        attributed.addAttribute(.foregroundColor, value: UIColor.neutral800, range: fullRange)

        let hobbyRange = NSRange(location: 0, length: hobbyName.utf16.count)
        attributed.addAttribute(.foregroundColor, value: UIColor.secondary003, range: hobbyRange)

        subtitleLabel.attributedText = attributed
    }

    private func layout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(selectedHobbyCard)
        contentView.addSubview(collectionView)
        contentView.addSubview(customInputButtonView)
        customInputButtonView.addSubview(customInputIconView)
        customInputButtonView.addSubview(customInputTitleLabel)
        customInputButtonView.addSubview(customInputCheckView)

        // ScrollView
        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }

        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // Selected Hobby Card
        selectedHobbyCard.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // CollectionView
        collectionView.snp.makeConstraints {
            $0.top.equalTo(selectedHobbyCard.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            collectionViewHeightConstraint = $0.height.equalTo(0).constraint
        }

        // Custom Input Button
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

extension PurposeSelectionView {
    func updateCollectionViewHeight() {
        layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeightConstraint?.update(offset: contentHeight)
        layoutIfNeeded()
    }

    func updateCustomInputButton(purposeName: String) {
        customInputButtonView.layer.borderColor = UIColor.action001.cgColor
        customInputTitleLabel.setTextWithTypography(purposeName, style: .header14)
        customInputTitleLabel.textColor = .neutral800
        customInputCheckView.isHidden = false
    }

    func resetCustomInputButton() {
        customInputButtonView.layer.borderColor = UIColor.stroke001.cgColor
        customInputTitleLabel.setTextWithTypography("원하는 목적이 없으신가요?", style: .header14)
        customInputTitleLabel.textColor = .neutral800
        customInputCheckView.isHidden = true
    }
}
