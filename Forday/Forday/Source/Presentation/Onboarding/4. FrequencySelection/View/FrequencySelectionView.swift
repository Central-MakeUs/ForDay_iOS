//
//  FrequencySelectionView.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import UIKit
import SnapKit
import Then

class FrequencySelectionView: UIView {

    // MARK: - Properties

    private let contentView = UIView()

    // Edit Mode Navigation
    private let editNavigationView = UIView()
    private let closeButton = UIButton()
    private let editTitleLabel = UILabel()

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let selectedHobbyCard = SelectedHobbyCardView()
    let recommendLabel = UILabel()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    // Edit Mode Button
    private let buttonContainerView = UIView()
    private let changeButton = UIButton()

    // Edit Mode State
    private(set) var isEditMode: Bool = false

    // MARK: - Callbacks

    var onCloseButtonTapped: (() -> Void)?
    var onChangeButtonTapped: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configureHobbyCard(icon: UIImage?, title: String, time: String?, purpose: String?) {
        selectedHobbyCard.configure(icon: icon, title: title)
        selectedHobbyCard.updateInfo(time: time, purpose: purpose)
        configureSubtitle(hobbyName: title)
    }
}

// Setup

extension FrequencySelectionView {
    private func style() {
        backgroundColor = .neutral50

        // Edit Mode Navigation (initially hidden)
        editNavigationView.do {
            $0.backgroundColor = .neutral50
            $0.isHidden = true
        }

        closeButton.do {
            $0.setImage(.Icon.xmark, for: .normal)
            $0.tintColor = .neutral800
            $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        }

        editTitleLabel.do {
            $0.setTextWithTypography("취미 정보", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        titleLabel.do {
            $0.setTextWithTypography("주 몇 회 하실 거예요?", style: .header20)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            $0.numberOfLines = 0
        }

        recommendLabel.do {
            $0.setTextWithTypography("추천", style: .body14)
            $0.textColor = .action001
            $0.textAlignment = .center
        }

        collectionView.do {
            $0.backgroundColor = .clear
            $0.register(FrequencyButtonCell.self, forCellWithReuseIdentifier: FrequencyButtonCell.identifier)
        }

        // Edit Mode Button (initially hidden)
        buttonContainerView.do {
            $0.backgroundColor = .neutral50
            $0.isHidden = true
        }

        changeButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .primary001
            config.baseForegroundColor = .neutralWhite
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 0, bottom: 18, trailing: 0)
            $0.configuration = config

            $0.setTitleWithTypography("변경하기", style: .header16)
            $0.addTarget(self, action: #selector(changeButtonTapped), for: .touchUpInside)
        }
    }

    @objc private func closeButtonTapped() {
        onCloseButtonTapped?()
    }

    @objc private func changeButtonTapped() {
        onChangeButtonTapped?()
    }

    private func configureSubtitle(hobbyName: String) {
        let suffix = "를 일주일에 몇 번 할까요?\n(처음에는 작게 시작해도 좋아요! 언제든지 변경 가능해요.)"
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
        addSubview(editNavigationView)
        addSubview(contentView)
        addSubview(buttonContainerView)

        editNavigationView.addSubview(closeButton)
        editNavigationView.addSubview(editTitleLabel)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(selectedHobbyCard)
        contentView.addSubview(recommendLabel)
        contentView.addSubview(collectionView)

        buttonContainerView.addSubview(changeButton)

        // Edit Navigation View
        editNavigationView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        editTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        // ContentView
        contentView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
        }

        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.leading.trailing.equalToSuperview()
        }

        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }

        // Selected Hobby Card
        selectedHobbyCard.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }

        // Recommend Label
        recommendLabel.snp.makeConstraints {
            $0.top.equalTo(selectedHobbyCard.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }

        // CollectionView
        collectionView.snp.makeConstraints {
            $0.top.equalTo(recommendLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        // Button Container View
        buttonContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(76)
        }

        changeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        }
    }

    // MARK: - Edit Mode

    func setEditMode(_ isEditMode: Bool) {
        self.isEditMode = isEditMode
        editNavigationView.isHidden = !isEditMode
        buttonContainerView.isHidden = !isEditMode

        // Update content view top constraint based on edit mode
        contentView.snp.remakeConstraints {
            if isEditMode {
                $0.top.equalTo(editNavigationView.snp.bottom)
            } else {
                $0.top.equalTo(safeAreaLayoutGuide).offset(24)
            }
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(isEditMode ? buttonContainerView.snp.top : self)
        }
    }
}

#if DEBUG
#Preview {
    FrequencySelectionView()
}
#endif
