//
//  ReactionUsersListViewController.swift
//  Forday
//
//  Created by Subeen on 4/7/26.
//

import UIKit
import SnapKit
import Then
import Combine

/// 특정 리액션 타입 또는 전체의 유저 목록을 표시하는 ViewController
final class ReactionUsersListViewController: UIViewController {

    // MARK: - UI Components

    private let tableView = UITableView()
    private let emptyLabel = UILabel()

    // MARK: - Properties

    private let reactionType: ReactionType?  // nil이면 전체
    private var users: [ReactionUserItem] = []
    private var lastReactionId: Int?
    private var hasNext: Bool = false
    private var isLoadingMore = false
    private var hasStartedDragging = false

    var onLoadMore: ((ReactionType?, Int?) -> Void)?

    // MARK: - Initialization

    init(reactionType: ReactionType?) {
        self.reactionType = reactionType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupLayout()
        setupTableView()
    }

    // MARK: - Configuration

    func configure(with tabData: ReactionTabData) {
        self.users = tabData.users
        self.lastReactionId = tabData.lastReactionId
        self.hasNext = tabData.hasNext

        updateEmptyState()
        tableView.reloadData()
    }

    func appendUsers(_ newUsers: [ReactionUserItem], lastReactionId: Int?, hasNext: Bool) {
        self.users.append(contentsOf: newUsers)
        self.lastReactionId = lastReactionId
        self.hasNext = hasNext
        self.isLoadingMore = false

        tableView.reloadData()
    }

    private func updateEmptyState() {
        emptyLabel.isHidden = !users.isEmpty
        tableView.isHidden = users.isEmpty
    }
}

// MARK: - Setup

extension ReactionUsersListViewController {
    private func setupStyle() {
        view.backgroundColor = .systemBackground

        emptyLabel.do {
            $0.setTextWithTypography("아직 감정 표현이 없어요", style: .label14, alignment: .center)
            $0.textColor = .neutral400
            $0.isHidden = true
        }
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        tableView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func setupTableView() {
        tableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.register(ReactionUserListCell.self, forCellReuseIdentifier: "ReactionUserListCell")
            $0.separatorStyle = .none
            $0.backgroundColor = .clear
            $0.rowHeight = 44
            $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ReactionUsersListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReactionUserListCell", for: indexPath) as? ReactionUserListCell else {
            return UITableViewCell()
        }

        let user = users[indexPath.row]
        cell.configure(with: user)
        return cell
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hasStartedDragging = true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard hasStartedDragging, hasNext, !isLoadingMore else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height

        // 바닥에서 100pt 전에 다음 페이지 로드
        let paginationTriggerOffset = max(0, contentHeight - frameHeight - 100)
        if offsetY > paginationTriggerOffset {
            guard let lastReactionId = lastReactionId else { return }
            isLoadingMore = true
            onLoadMore?(reactionType, lastReactionId)
        }
    }
}
