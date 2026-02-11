//
//  HobbySettingsView.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import UIKit
import SnapKit
import Then

class HobbySettingsView: UIView {

    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let segmentContainerView = UIView()
    let segmentedControl = UISegmentedControl(items: ["진행중", "보관함"])
    private let underlineView = UIView()
    let tableView = UITableView(frame: .zero, style: .plain)

    private var underlineLeadingConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func style() {
        backgroundColor = .neutral50

        // Header
        headerLabel.do {
            $0.text = "내 취미정보를 수정하고 추가하기"
            $0.applyTypography(.header20)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        // Subtitle with highlighted "2개"
        let fullText = "마음에 드는 취미는 최대 2개까지 선택할 수 있어요."
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.neutral700, range: NSRange(location: 0, length: fullText.count))

        if let range = fullText.range(of: "2개") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemPink, range: nsRange)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .semibold), range: nsRange)
        }

        subtitleLabel.do {
            $0.attributedText = attributedString
            $0.font = UIFont.systemFont(ofSize: 14)
            $0.numberOfLines = 0
        }

        // Segmented Control (custom style)
        segmentedControl.do {
            $0.selectedSegmentIndex = 0
            $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
            $0.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            $0.setTitleTextAttributes([.foregroundColor: UIColor.neutral500, .font: UIFont.systemFont(ofSize: 16)], for: .normal)
            $0.setTitleTextAttributes([.foregroundColor: UIColor.neutral900, .font: UIFont.systemFont(ofSize: 16, weight: .semibold)], for: .selected)
        }

        // Underline
        underlineView.do {
            $0.backgroundColor = .neutral900
        }

        // TableView
        tableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.showsVerticalScrollIndicator = false
            $0.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
            $0.register(HobbySettingsCell.self, forCellReuseIdentifier: HobbySettingsCell.identifier)
            $0.register(AddHobbyCell.self, forCellReuseIdentifier: AddHobbyCell.identifier)
        }
    }

    private func layout() {
        addSubview(headerLabel)
        addSubview(subtitleLabel)
        addSubview(segmentContainerView)
        addSubview(tableView)

        segmentContainerView.addSubview(segmentedControl)
        segmentContainerView.addSubview(underlineView)

        headerLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        segmentContainerView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        segmentedControl.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        underlineView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
            $0.width.equalTo(segmentedControl).dividedBy(2)
            underlineLeadingConstraint = $0.leading.equalToSuperview().constraint
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(segmentContainerView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    // Public Methods

    func updateSegmentedControl(inProgressCount: Int, archivedCount: Int, selectedIndex: Int) {
        segmentedControl.setTitle("진행중 \(inProgressCount)", forSegmentAt: 0)
        segmentedControl.setTitle("보관함 \(archivedCount)", forSegmentAt: 1)
        segmentedControl.selectedSegmentIndex = selectedIndex
        animateUnderline(to: selectedIndex)
    }

    func animateUnderline(to index: Int) {
        // Ensure layout is complete before calculating segment width
        if segmentedControl.frame.width == 0 {
            layoutIfNeeded()
        }

        let segmentWidth = segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
        let leadingOffset = segmentWidth * CGFloat(index)

        underlineLeadingConstraint?.update(offset: leadingOffset)

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.layoutIfNeeded()
        }
    }

    func reloadTableView() {
        tableView.reloadData()
    }
}

#Preview {
    HobbySettingsView()
}
