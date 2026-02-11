//
//  TimeSelectionView.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import UIKit
import SnapKit
import Then

class TimeSelectionView: UIView {

    // MARK: - Properties

    private let contentView = UIView()
    private let hobbyView = UIView()

    // Edit Mode Navigation
    private let editNavigationView = UIView()
    private let closeButton = UIButton()
    private let editTitleLabel = UILabel()

    let titleLabel = UILabel()
    let hobbyLabel = UILabel()
    let subtitleLabel = UILabel()
    let selectedHobbyCard = SelectedHobbyCardView()
    let timeSlider = TimeSliderView()

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
}

// Setup

extension TimeSelectionView {
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
            $0.text = "한 번에 얼마나 할 수 있나요?"
            $0.applyTypography(.header20)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            $0.applyTypography(.label14)
            $0.textColor = .neutral800
            $0.numberOfLines = 0
        }

        hobbyView.do {
            $0.backgroundColor = .bg001
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

    // Configure

    func configureHobbyCard(icon: UIImage?, title: String) {
        selectedHobbyCard.configure(icon: icon, title: title)
        configureSubtitle(hobbyName: title)
    }

    private func configureSubtitle(hobbyName: String) {
        let suffix = "에 투자할 수 있는 시간을 선택해주세요.\n처음엔 짧게 시작하는 게 좋아요. 습관이 되면 자연스럽게 늘어나요!"
        let fullText = hobbyName + suffix

        let attributed = NSMutableAttributedString(string: fullText)

        // Typography 속성 + 기본 색상 적용
        let fullRange = NSRange(location: 0, length: fullText.utf16.count)
        attributed.addAttributes(TypographyStyle.label14.attributes, range: fullRange)
        attributed.addAttribute(.foregroundColor, value: UIColor.neutral800, range: fullRange)

        // 취미명 부분만 .secondary003
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
        contentView.addSubview(hobbyView)
        contentView.addSubview(timeSlider)

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
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
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

        selectedHobbyCard.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // Time Slider
        timeSlider.snp.makeConstraints {
            $0.top.equalTo(selectedHobbyCard.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-22)
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
                $0.top.equalTo(safeAreaLayoutGuide)
            }
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(isEditMode ? buttonContainerView.snp.top : safeAreaLayoutGuide)
            $0.width.equalToSuperview()
        }
    }
}

#Preview {
    TimeSelectionViewController(viewModel: .init())
}
