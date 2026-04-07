//
//  ReactionTabBar.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import UIKit
import SnapKit
import Then
import Combine

/// 감정 반응 바텀시트의 커스텀 탭 바
final class ReactionTabBar: UIView {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let bottomBorder = UIView()

    private var tabButtons: [ReactionTabButton] = []

    // MARK: - Properties

    private var selectedIndex: Int = 0
    let tabSelected = PassthroughSubject<Int, Never>()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    /// 탭 바 구성 (전체, 멋져요, 짱이야, 대단해, 화이팅)
    func configure(with summary: ReactionSummary) {
        // Clear existing tabs
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add tab buttons
        let tabs: [(title: String, count: Int, icon: UIImage?)] = [
            ("전체", summary.totalCount, nil),
            ("", summary.awesome, .Reaction.awesome),
            ("", summary.great, .Reaction.great),
            ("", summary.amazing, .Reaction.amazing),
            ("", summary.fighting, .Reaction.fighting)
        ]

        for (index, tab) in tabs.enumerated() {
            let button = ReactionTabButton(
                title: tab.title,
                count: tab.count,
                icon: tab.icon,
                isSelected: index == 0
            )
            button.tag = index
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)

            stackView.addArrangedSubview(button)
            tabButtons.append(button)
        }

        // Select first tab by default
        selectedIndex = 0
    }

    func selectTab(at index: Int) {
        guard index != selectedIndex, index < tabButtons.count else { return }

        tabButtons[selectedIndex].setSelected(false)
        tabButtons[index].setSelected(true)
        selectedIndex = index
    }

    @objc private func tabButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index != selectedIndex else { return }

        selectTab(at: index)
        tabSelected.send(index)
    }
}

// MARK: - Setup

extension ReactionTabBar {
    private func setupStyle() {
        backgroundColor = .clear

        scrollView.do {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
        }

        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 0
            $0.alignment = .fill
            $0.distribution = .fillProportionally
        }

        bottomBorder.do {
            $0.backgroundColor = .stroke001
        }
    }

    private func setupLayout() {
        addSubview(scrollView)
        addSubview(bottomBorder)
        scrollView.addSubview(stackView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        bottomBorder.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

// MARK: - ReactionTabButton

private final class ReactionTabButton: UIButton {

    // MARK: - UI Components

    private let iconImageView = UIImageView()
    private let countLabel = UILabel()
    private let bottomIndicator = UIView()

    // MARK: - Properties

    private let icon: UIImage?
    private let count: Int

    // MARK: - Initialization

    init(title: String, count: Int, icon: UIImage?, isSelected: Bool) {
        self.icon = icon
        self.count = count
        super.init(frame: .zero)

        setupStyle()
        setupLayout()
        configure(title: title, count: count, icon: icon)
        setSelected(isSelected)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configure(title: String, count: Int, icon: UIImage?) {
        if let icon = icon {
            // Icon tab
            iconImageView.image = icon
            iconImageView.isHidden = false
            setTitle(nil, for: .normal)
        } else {
            // Text tab (전체)
            iconImageView.isHidden = true
            let attributedTitle = NSAttributedString(
                string: title,
                attributes: TypographyStyle.body14.attributes
            )
            setAttributedTitle(attributedTitle, for: .normal)
        }

        countLabel.setTextWithTypography("\(count)", style: .label14)
    }

    func setSelected(_ selected: Bool) {
        if icon != nil {
            // Icon tab
            iconImageView.tintColor = selected ? .neutral800 : .neutral400
            countLabel.textColor = selected ? .neutral800 : .neutral400
        } else {
            // Text tab
            if let currentTitle = attributedTitle(for: .normal)?.string ?? titleLabel?.text {
                let style: TypographyStyle = selected ? .body14 : .label14
                var attributes = style.attributes
                attributes[.foregroundColor] = selected ? UIColor.neutral800 : UIColor.neutral400

                let attributedTitle = NSAttributedString(
                    string: currentTitle,
                    attributes: attributes
                )
                setAttributedTitle(attributedTitle, for: .normal)
            }
            countLabel.textColor = selected ? .neutral800 : .neutral400
        }

        bottomIndicator.isHidden = !selected
    }

    private func setupStyle() {
        backgroundColor = .clear

        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }

        countLabel.do {
            $0.textColor = .neutral400
        }

        bottomIndicator.do {
            $0.backgroundColor = .neutral800
            $0.isHidden = true
        }
    }

    private func setupLayout() {
        let containerView = UIView()
        addSubview(containerView)
        addSubview(bottomIndicator)

        containerView.addSubview(iconImageView)
        containerView.addSubview(countLabel)

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().offset(8)
            $0.bottom.lessThanOrEqualTo(bottomIndicator.snp.top).offset(-8)
        }

        // Icon tab layout
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(16)
        }

        countLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        bottomIndicator.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }

        // Set button size
        self.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(50)
            $0.height.equalTo(40)
        }
    }
}
