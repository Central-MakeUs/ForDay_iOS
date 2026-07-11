//
//  PrivacyDropdownView.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import UIKit
import SnapKit
import Then

class PrivacyDropdownView: UIView {

    // Properties

    private let tableView = UITableView()

    private let privacyOptions: [Privacy] = [.public, .friend, .private]
    private var selectedIndexPath: IndexPath?
    var onPrivacySelected: ((Privacy) -> Void)?

    // Initialization

    init(selectedPrivacy: Privacy? = nil) {
        super.init(frame: .zero)
        if let selected = selectedPrivacy,
           let index = privacyOptions.firstIndex(of: selected) {
            selectedIndexPath = IndexPath(row: index, section: 0)
        }
        style()
        layout()
        setupTableView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension PrivacyDropdownView {
    private func style() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 12

        tableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.isScrollEnabled = false
            $0.bounces = false
            $0.showsVerticalScrollIndicator = false
            $0.clipsToBounds = true
        }
    }

    private func layout() {
        addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PrivacyDropdownCell.self, forCellReuseIdentifier: PrivacyDropdownCell.identifier)
    }
}

// Public Methods

extension PrivacyDropdownView {
    func show(in parentView: UIView, below sourceView: UIView) {
        parentView.addSubview(self)

        // 3개 고정
        let rowHeight: CGFloat = 48
        let totalHeight = CGFloat(privacyOptions.count) * rowHeight

        self.snp.makeConstraints {
            $0.top.equalTo(sourceView.snp.bottom).offset(8)
            $0.trailing.equalTo(sourceView)
            $0.width.equalTo(120)
            $0.height.equalTo(totalHeight)
        }

        // Fade in animation
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

// UITableViewDataSource

extension PrivacyDropdownView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return privacyOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PrivacyDropdownCell.identifier, for: indexPath) as? PrivacyDropdownCell else {
            return UITableViewCell()
        }

        let privacy = privacyOptions[indexPath.row]
        let isSelected = indexPath == selectedIndexPath
        cell.configure(with: privacy, isSelected: isSelected)

        return cell
    }
}

// UITableViewDelegate

extension PrivacyDropdownView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 이전 선택 셀 해제
        if let previousIndexPath = selectedIndexPath {
            tableView.cellForRow(at: previousIndexPath)?.isSelected = false
        }

        // 새로운 선택 셀 업데이트
        selectedIndexPath = indexPath

        let selectedPrivacy = privacyOptions[indexPath.row]
        onPrivacySelected?(selectedPrivacy)
    }
}

// MARK: - PrivacyDropdownCell

class PrivacyDropdownCell: UITableViewCell {

    static let identifier = "PrivacyDropdownCell"

    private let privacyLabel = UILabel()
    private let selectedBackgroundContainerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        // 선택 배경 뷰 설정
        selectedBackgroundContainerView.do {
            $0.backgroundColor = .neutral100
            $0.layer.cornerRadius = 8
            $0.isHidden = true
        }

        privacyLabel.do {
            $0.textColor = .neutral500
            $0.textAlignment = .center
        }

        contentView.addSubview(selectedBackgroundContainerView)
        contentView.addSubview(privacyLabel)

        selectedBackgroundContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.bottom.equalToSuperview().inset(4)
        }

        privacyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        updateSelectionUI(selected: selected)
    }

    private func updateSelectionUI(selected: Bool) {
        if selected {
            selectedBackgroundContainerView.isHidden = false
            privacyLabel.applyTypography(.header14)
            privacyLabel.textColor = .neutral800
        } else {
            selectedBackgroundContainerView.isHidden = true
            privacyLabel.applyTypography(.label14)
            privacyLabel.textColor = .neutral600
        }
    }

    func configure(with privacy: Privacy, isSelected: Bool) {
        privacyLabel.text = privacy.title

        // 선택 상태 적용
        updateSelectionUI(selected: isSelected)
    }
}
