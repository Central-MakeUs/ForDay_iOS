//
//  StoriesTabSegmentControl.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import UIKit
import SnapKit
import Then

final class StoriesTabSegmentControl: UIView {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let indicatorView = UIView()

    // MARK: - Properties

    private var tabButtons: [UIButton] = []
    private var tabs: [StoriesTab] = []
    private(set) var selectedIndex: Int = 0

    var onTabSelected: ((Int, StoriesTab) -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with tabs: [StoriesTab]) {
        self.tabs = tabs

        // Clear existing buttons
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()

        // Create new buttons
        tabs.enumerated().forEach { index, tab in
            let button = createTabButton(for: tab, at: index)
            tabButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        // Select first tab by default
        if !tabs.isEmpty {
            selectTab(at: 0, animated: false)
        }
    }

    func selectTab(at index: Int, animated: Bool = true) {
        guard index >= 0 && index < tabs.count else { return }

        selectedIndex = index
        updateButtonStates()
        moveIndicator(to: index, animated: animated)
        scrollToSelectedTab(at: index, animated: animated)
    }

    private func createTabButton(for tab: StoriesTab, at index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(tab.hobbyName, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        button.addAction(UIAction { [weak self] _ in
            self?.handleTabTapped(at: index)
        }, for: .touchUpInside)

        return button
    }

    private func handleTabTapped(at index: Int) {
        guard index != selectedIndex else { return }

        selectTab(at: index, animated: true)
        onTabSelected?(index, tabs[index])
    }

    private func updateButtonStates() {
        tabButtons.enumerated().forEach { index, button in
            let isSelected = index == selectedIndex

            if isSelected {
                button.setTitleColor(.neutral900, for: .normal)
            } else {
                button.setTitleColor(.neutral400, for: .normal)
            }
        }
    }

    private func moveIndicator(to index: Int, animated: Bool) {
        guard index >= 0 && index < tabButtons.count else { return }

        let button = tabButtons[index]

        let animationBlock = {
            self.indicatorView.snp.remakeConstraints {
                $0.bottom.equalTo(self.scrollView)
                $0.centerX.equalTo(button)
                $0.width.equalTo(button.snp.width).offset(-32)
                $0.height.equalTo(2)
            }
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.25) {
                animationBlock()
            }
        } else {
            animationBlock()
        }
    }

    private func scrollToSelectedTab(at index: Int, animated: Bool) {
        guard index >= 0 && index < tabButtons.count else { return }

        let button = tabButtons[index]

        // Calculate the target scroll position to center the selected button
        let buttonCenterX = button.frame.midX
        let scrollViewCenterX = scrollView.bounds.width / 2
        var targetOffsetX = buttonCenterX - scrollViewCenterX

        // Clamp to valid range
        let maxOffsetX = max(0, scrollView.contentSize.width - scrollView.bounds.width)
        targetOffsetX = max(0, min(targetOffsetX, maxOffsetX))

        scrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: animated)
    }
}

// MARK: - Setup

extension StoriesTabSegmentControl {
    private func style() {
        backgroundColor = .systemBackground

        scrollView.do {
            $0.showsHorizontalScrollIndicator = false
            $0.bounces = true
        }

        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 0
            $0.alignment = .center
            $0.distribution = .fillProportionally
        }

        indicatorView.do {
            $0.backgroundColor = .neutral900
        }
    }

    private func layout() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        addSubview(indicatorView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(scrollView)
        }

        // Indicator will be positioned dynamically when tabs are configured
    }
}
