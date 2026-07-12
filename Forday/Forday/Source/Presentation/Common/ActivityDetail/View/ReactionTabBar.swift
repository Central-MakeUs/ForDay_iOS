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

    private let stackView = UIStackView()
    private let bottomBorder = UIView()
    private let spacerView = UIView()

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
        let debugBackgroundColors = Array<UIColor?>(repeating: nil, count: tabs.count)

        for (index, tab) in tabs.enumerated() {
            let button = ReactionTabButton(
                title: tab.title,
                count: tab.count,
                icon: tab.icon,
                isSelected: index == 0,
                debugBackgroundColor: debugBackgroundColors[index]
            )
            button.tag = index
            button.addTarget(self, action: #selector(tabButtonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(tabButtonTouchCancelled(_:)), for: [.touchCancel, .touchUpOutside, .touchDragExit])

            stackView.addArrangedSubview(button)
            tabButtons.append(button)
        }

        stackView.addArrangedSubview(spacerView)

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
        print("🟣 [ReactionTabBar] touchUpInside index=\(index), selectedIndex=\(selectedIndex)")

        guard index != selectedIndex else {
            print("🟣 [ReactionTabBar] ignored - already selected index=\(index)")
            return
        }

        tabSelected.send(index)
    }

    @objc private func tabButtonTouchDown(_ sender: UIButton) {
        print("🟣 [ReactionTabBar] touchDown index=\(sender.tag), selectedIndex=\(selectedIndex)")
    }

    @objc private func tabButtonTouchCancelled(_ sender: UIButton) {
        print("🟣 [ReactionTabBar] touch cancelled/outside/dragExit index=\(sender.tag), selectedIndex=\(selectedIndex)")
    }
}

// MARK: - Setup

extension ReactionTabBar {
    private func setupStyle() {
        backgroundColor = .clear

        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 0
            $0.alignment = .fill
            $0.distribution = .fill
        }

        bottomBorder.do {
            $0.backgroundColor = .stroke001
        }

        spacerView.do {
            $0.backgroundColor = .clear
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }

    private func setupLayout() {
        addSubview(stackView)
        addSubview(bottomBorder)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
    private let textLabel = UILabel()
    private let countLabel = UILabel()
    private let bottomIndicator = UIView()

    // MARK: - Properties

    private let icon: UIImage?
    private let count: Int

    // MARK: - Initialization

    init(title: String, count: Int, icon: UIImage?, isSelected: Bool, debugBackgroundColor: UIColor? = nil) {
        self.icon = icon
        self.count = count
        super.init(frame: .zero)

        setupStyle()
        backgroundColor = debugBackgroundColor ?? .clear
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
            textLabel.isHidden = true
        } else {
            // Text tab (전체)
            iconImageView.isHidden = true
            textLabel.isHidden = false
            textLabel.setTextWithTypography(title, style: .body14)
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
            let style: TypographyStyle = selected ? .body14 : .label14
            textLabel.setTextWithTypography(textLabel.text ?? "", style: style)
            textLabel.textColor = selected ? .neutral800 : .neutral400
            countLabel.textColor = selected ? .neutral800 : .neutral400
        }

        bottomIndicator.isHidden = !selected
    }

    private func setupStyle() {
        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
            $0.isUserInteractionEnabled = false
        }

        textLabel.do {
            $0.textColor = .neutral400
            $0.isHidden = true
            $0.isUserInteractionEnabled = false
        }

        countLabel.do {
            $0.textColor = .neutral400
            $0.isUserInteractionEnabled = false
        }

        bottomIndicator.do {
            $0.backgroundColor = .neutral800
            $0.isHidden = true
            $0.isUserInteractionEnabled = false
        }
    }

    private func setupLayout() {
        // StackView를 사용하여 간격을 일관되게 4px로 관리
        let stackView = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 4  // Figma 디자인에 따른 4px 간격
            $0.alignment = .center
            $0.distribution = .fill
        }

        addSubview(stackView)
        addSubview(bottomIndicator)

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(countLabel)

        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().offset(8)
            $0.bottom.lessThanOrEqualTo(bottomIndicator.snp.top).offset(-8)
        }

        // Icon size
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(16)
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
