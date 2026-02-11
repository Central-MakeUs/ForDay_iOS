//
//  ActivityListView.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import UIKit
import SnapKit
import Then

class ActivityListView: UIView {

    // MARK: - UI Components

    // Custom Navigation
    private let navigationView = UIView()
    let backButton = UIButton()
    private let titleLabel = UILabel()
    let addButton = UIButton()

    let tableView = UITableView()
    private let defaultLabel = UILabel()

    private let emptyView = UIView()
    private let emptyBubbleImageView = UIImageView()
    private let emptyBoxImageView = UIImageView()
    private let emptyLabel = UILabel()
    private let createActivityButton = UIButton()

    // MARK: - Callbacks

    var onCreateActivityTapped: (() -> Void)?

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

// MARK: - Setup

extension ActivityListView {
    private func style() {
        backgroundColor = .neutral50

        // Custom Navigation
        navigationView.do {
            $0.backgroundColor = .neutral50
        }

        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral800
        }

        titleLabel.do {
            $0.setTextWithTypography("활동 리스트", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        addButton.do {
            $0.setImage(.Icon.plus, for: .normal)
            $0.tintColor = .neutral800
        }

        emptyView.do {
            $0.isHidden = true
        }

        tableView.do {
            $0.backgroundColor = .neutral50
            $0.separatorStyle = .none
            $0.register(ActivityCardCell.self, forCellReuseIdentifier: ActivityCardCell.identifier)
            $0.estimatedRowHeight = 48
        }

        defaultLabel.do {
            $0.setTextWithTypography("현재 진행하고 있는 활동들이에요.", style: .label14)
            $0.textColor = .neutral800
            $0.textAlignment = .left
        }

        emptyBubbleImageView.do {
            $0.image = .Icon.emptyBubble
            $0.contentMode = .scaleAspectFit
        }

        emptyBoxImageView.do {
            $0.image = .Icon.emptyBox
            $0.contentMode = .scaleAspectFit
        }

        emptyLabel.do {
            $0.setTextWithTypography("진행 중인 취미활동이 없어요.", style: .body14)
            $0.textColor = .neutral600
        }

        createActivityButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .primary003
            config.baseForegroundColor = .action001
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 40, bottom: 12, trailing: 40)
            $0.configuration = config

            $0.setTitleWithTypography("취미활동 추가하기", style: .header14)
            $0.addTarget(self, action: #selector(createActivityButtonTapped), for: .touchUpInside)
        }
    }

    @objc private func createActivityButtonTapped() {
        onCreateActivityTapped?()
    }

    private func layout() {
        // Custom Navigation
        addSubview(navigationView)
        navigationView.addSubview(backButton)
        navigationView.addSubview(titleLabel)
        navigationView.addSubview(addButton)

        addSubview(tableView)
        addSubview(defaultLabel)
        addSubview(emptyView)

        emptyView.addSubview(emptyBubbleImageView)
        emptyView.addSubview(emptyBoxImageView)
        emptyView.addSubview(emptyLabel)
        emptyView.addSubview(createActivityButton)

        // Navigation View
        navigationView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        // Content
        defaultLabel.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(17)
            $0.leading.equalToSuperview().inset(20)
        }

        tableView.snp.makeConstraints {
            $0.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            $0.top.equalTo(defaultLabel.snp.bottom).offset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }

        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        emptyBubbleImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.size.equalTo(48)
        }

        emptyBoxImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(emptyBubbleImageView.snp.bottom).offset(3)
            $0.width.equalTo(160)
            $0.height.equalTo(140)
        }

        emptyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(emptyBoxImageView.snp.bottom).offset(40)
        }

        createActivityButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(emptyLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(43)
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - Public Methods

extension ActivityListView {
    func setEmptyState(_ isEmpty: Bool) {
        defaultLabel.isHidden = isEmpty
        tableView.isHidden = isEmpty
        emptyView.isHidden = !isEmpty
    }
}

#if DEBUG
#Preview("ActivityListView - With Data") {
    let listView = ActivityListView()

    // TableView DataSource를 위한 간단한 클래스
    class PreviewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return Activity.previewList.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCardCell.identifier, for: indexPath) as? ActivityCardCell else {
                return UITableViewCell()
            }
            cell.configure(with: Activity.previewList[indexPath.row])
            return cell
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return ActivityCardCell.cellHeight
        }
    }

    let dataSource = PreviewDataSource()
    listView.tableView.dataSource = dataSource
    listView.tableView.delegate = dataSource

    // DataSource를 유지하기 위해 associated object 사용
    objc_setAssociatedObject(listView, "dataSource", dataSource, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    return listView
}

#Preview("ActivityListView - Empty") {
    let listView = ActivityListView()
    listView.setEmptyState(true)
    return listView
}
#endif
