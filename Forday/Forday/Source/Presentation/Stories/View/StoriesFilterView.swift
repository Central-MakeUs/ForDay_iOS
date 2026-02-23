//
//  StoriesFilterView.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import UIKit
import SnapKit
import Then

final class StoriesFilterView: UIView {

    // MARK: - UI Components

    private let stackView = UIStackView()
    private var filterButtons: [UIButton] = []

    // MARK: - Properties

    private(set) var selectedFilter: StoryFilterType = .all
    var onFilterSelected: ((StoryFilterType) -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func selectFilter(_ filter: StoryFilterType) {
        selectedFilter = filter
        updateButtonStates()
    }

    private func setupButtons() {
        StoryFilterType.allCases.forEach { filter in
            let button = createFilterButton(for: filter)
            filterButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        // Select "전체" by default
        updateButtonStates()
    }

    private func createFilterButton(for filter: StoryFilterType) -> UIButton {
        let button = UIButton(type: .system)

        var config = UIButton.Configuration.filled()
        config.title = filter.displayName
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.background.cornerRadius = 16
        config.baseForegroundColor = .neutral600
        config.baseBackgroundColor = .neutral50

        var titleAttr = AttributedString(filter.displayName)
        titleAttr.font = TypographyStyle.body14.font
        config.attributedTitle = titleAttr

        button.configuration = config

        button.addAction(UIAction { [weak self] _ in
            self?.handleFilterTapped(filter)
        }, for: .touchUpInside)

        return button
    }

    private func handleFilterTapped(_ filter: StoryFilterType) {
        guard filter != selectedFilter else { return }
        selectedFilter = filter
        updateButtonStates()
        onFilterSelected?(filter)
    }

    private func updateButtonStates() {
        StoryFilterType.allCases.enumerated().forEach { index, filter in
            let button = filterButtons[index]
            let isSelected = filter == selectedFilter

            guard var config = button.configuration else { return }
            config.baseBackgroundColor = isSelected ? .neutral900 : .neutral50
            config.baseForegroundColor = isSelected ? .neutralWhite : .neutral600
            button.configuration = config
        }
    }
}

// MARK: - Setup

extension StoriesFilterView {
    private func style() {
        backgroundColor = .neutralWhite

        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
    }

    private func layout() {
        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
    }
}
