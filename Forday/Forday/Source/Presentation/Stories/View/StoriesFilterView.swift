//
//  StoriesFilterView.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import UIKit
import SnapKit
import Then

enum StoriesFilter: String, CaseIterable {
    case all = "전체"
    case funded = "자금 활용"
    case friend = "친구"
}

final class StoriesFilterView: UIView {

    // MARK: - UI Components

    private let stackView = UIStackView()
    private var filterButtons: [UIButton] = []

    // MARK: - Properties

    private(set) var selectedFilter: StoriesFilter = .all
    var onFilterSelected: ((StoriesFilter) -> Void)?

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

    func selectFilter(_ filter: StoriesFilter) {
        selectedFilter = filter
        updateButtonStates()
    }

    private func setupButtons() {
        StoriesFilter.allCases.forEach { filter in
            let button = createFilterButton(for: filter)
            filterButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        // Select "전체" by default
        updateButtonStates()
    }

    private func createFilterButton(for filter: StoriesFilter) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(filter.rawValue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        button.addAction(UIAction { [weak self] _ in
            self?.handleFilterTapped(filter)
        }, for: .touchUpInside)

        return button
    }

    private func handleFilterTapped(_ filter: StoriesFilter) {
        selectedFilter = filter
        updateButtonStates()
        onFilterSelected?(filter)
    }

    private func updateButtonStates() {
        StoriesFilter.allCases.enumerated().forEach { index, filter in
            let button = filterButtons[index]
            let isSelected = filter == selectedFilter

            if isSelected {
                button.backgroundColor = .neutral900
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .neutral50
                button.setTitleColor(.neutral600, for: .normal)
            }
        }
    }
}

// MARK: - Setup

extension StoriesFilterView {
    private func style() {
        backgroundColor = .systemBackground

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
