//
//  NotificationView.swift
//  Forday
//
//  Created by Subeen on 4/5/26.
//

import UIKit
import SnapKit
import Then

final class NotificationView: UIView {

    // MARK: - UI Components

    // Header
    private let headerView = UIView()
    let backButton = UIButton()
    private let titleLabel = UILabel()
    let settingsButton = UIButton()

    // Permission Banner
    let permissionBannerView = UIView()
    private let bannerTitleLabel = UILabel()
    private let bannerMessageLabel = UILabel()

    // TODO: 필터 버튼들 (전체, 소식글, 친구, 모임) - 확장성을 위해 나중에 추가
    // private let filterContainerView = UIView()
    // let allFilterButton = UIButton()
    // let recordFilterButton = UIButton()
    // let friendFilterButton = UIButton()
    // let groupFilterButton = UIButton()

    // TableView
    let tableView = UITableView()
    let refreshControl = UIRefreshControl()

    // Empty State
    let emptyStateView = EmptyStateView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func style() {
        backgroundColor = .bg001

        // Header
        headerView.do {
            $0.backgroundColor = .clear
        }

        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral800
        }

        titleLabel.do {
            $0.setTextWithTypography("내 알림", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        settingsButton.do {
            $0.setImage(.Icon.settings, for: .normal)
            $0.tintColor = .neutral800
        }

        // Permission Banner
        permissionBannerView.do {
            $0.backgroundColor = .bg002
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.isHidden = true  // 기본적으로 숨김
        }

        bannerTitleLabel.do {
            $0.setTextWithTypography("기기 알림 설정이 꺼져있어요.", style: .body14)
            $0.textColor = .neutral800
        }

        bannerMessageLabel.do {
            $0.numberOfLines = 0

            let text = "알림을 놓치지 않도록 알림 권한을 허용해주세요."
            let attributedString = NSMutableAttributedString(string: text)

            // 전체 스타일
            attributedString.addAttributes([
                .font: TypographyStyle.label12.font,
                .foregroundColor: UIColor.neutral500
            ], range: NSRange(location: 0, length: text.count))

            // "알림 권한" 부분만 오렌지색 + Bold
            if let range = text.range(of: "알림 권한") {
                let nsRange = NSRange(range, in: text)
                attributedString.addAttributes([
                    .font: TypographyStyle.label12.font,
                    .foregroundColor: UIColor.action001
                ], range: nsRange)
            }

            $0.attributedText = attributedString
        }

        // TableView
        tableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.refreshControl = refreshControl
            $0.showsVerticalScrollIndicator = false
            $0.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        }

        // Empty State
        emptyStateView.do {
            $0.isHidden = true
        }
    }

    private func layout() {
        addSubview(headerView)
        addSubview(permissionBannerView)
        addSubview(tableView)
        addSubview(emptyStateView)

        // Header
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        headerView.addSubview(settingsButton)

        // Permission Banner
        permissionBannerView.addSubview(bannerTitleLabel)
        permissionBannerView.addSubview(bannerMessageLabel)

        // Header Layout
        headerView.snp.makeConstraints {
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

        settingsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        // Permission Banner Layout
        permissionBannerView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(13)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        bannerTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        bannerMessageLabel.snp.makeConstraints {
            $0.top.equalTo(bannerTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }

        // TableView Layout
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // Empty State Layout
        emptyStateView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().inset(20)
        }
    }

    // MARK: - Public Methods

    /// 권한 미허가 배너 표시
    func showPermissionBanner() {
        permissionBannerView.isHidden = false

        // TableView top constraint 조정
        tableView.snp.remakeConstraints {
            $0.top.equalTo(permissionBannerView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    /// 권한 미허가 배너 숨김
    func hidePermissionBanner() {
        permissionBannerView.isHidden = true

        // TableView top constraint 원복
        tableView.snp.remakeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    /// Empty State 표시
    func showEmptyState() {
        emptyStateView.isHidden = false
        tableView.isHidden = true

        // Empty state 설정 (알림 없음)
        emptyStateView.configureForNotifications()
    }

    /// Empty State 숨김
    func hideEmptyState() {
        emptyStateView.isHidden = true
        tableView.isHidden = false
    }
}
