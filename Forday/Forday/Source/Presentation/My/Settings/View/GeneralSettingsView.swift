//
//  GeneralSettingsView.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit
import SnapKit
import Then

final class GeneralSettingsView: UIView {

    // MARK: - UI Components

    // Custom Navigation Bar
    private let navigationBarView = UIView()
    let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    // Content
    private let contentView = UIView()
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()

    // Section 1: 안내
    private let infoSectionView = UIView()
    private let infoHeaderLabel = UILabel()
    private let appVersionRow = SettingsRowView(title: "앱 버전", hasChevron: false, valueText: "1.0.0")
    let termsOfServiceRow = SettingsRowView(title: "서비스 이용약관", hasChevron: true)
    let privacyPolicyRow = SettingsRowView(title: "개인정보 보호정책", hasChevron: true)

    // Section 2: 계정
    private let accountSectionView = UIView()
    let logoutRow = SettingsRowView(title: "로그아웃", hasChevron: true)
    let deleteAccountButton = UIButton(type: .system)

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func updateAppVersion(_ version: String) {
        appVersionRow.updateValue(version)
    }
}

// MARK: - Setup

extension GeneralSettingsView {
    private func style() {
        backgroundColor = .bg002

        // Navigation Bar
        navigationBarView.do {
            $0.backgroundColor = .bg001
        }

        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral900
        }

        titleLabel.do {
            $0.setTextWithTypography("전체설정", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        // Content
        scrollView.do {
            $0.backgroundColor = .bg002
            $0.showsVerticalScrollIndicator = false
        }

        scrollContentView.do {
            $0.backgroundColor = .bg002
        }

        // Section 1: 안내
        infoSectionView.do {
            $0.backgroundColor = .bg001
        }

        infoHeaderLabel.do {
            $0.setTextWithTypography("안내", style: .body12)
            $0.textColor = UIColor(hex: "9B9EA9")  // blue gray30
        }

        // Section 2: 계정
        accountSectionView.do {
            $0.backgroundColor = .bg001
        }

        deleteAccountButton.do {
            $0.setTitle("탈퇴하기", for: .normal)
            $0.setTitleColor(.neutral400, for: .normal)
            $0.titleLabel?.font = TypographyStyle.body12.font
            $0.contentHorizontalAlignment = .left
        }
    }

    private func layout() {
        addSubview(navigationBarView)
        navigationBarView.addSubview(backButton)
        navigationBarView.addSubview(titleLabel)

        addSubview(scrollView)
        scrollView.addSubview(scrollContentView)

        // Section 1: 안내
        scrollContentView.addSubview(infoSectionView)
        infoSectionView.addSubview(infoHeaderLabel)
        infoSectionView.addSubview(appVersionRow)
        infoSectionView.addSubview(termsOfServiceRow)
        infoSectionView.addSubview(privacyPolicyRow)

        // Section 2: 계정
        scrollContentView.addSubview(accountSectionView)
        accountSectionView.addSubview(logoutRow)
        accountSectionView.addSubview(deleteAccountButton)

        // Navigation Bar Layout
        navigationBarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        // Scroll View Layout
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // Section 1: 안내
        infoSectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        infoHeaderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        appVersionRow.snp.makeConstraints {
            $0.top.equalTo(infoHeaderLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }

        termsOfServiceRow.snp.makeConstraints {
            $0.top.equalTo(appVersionRow.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }

        privacyPolicyRow.snp.makeConstraints {
            $0.top.equalTo(termsOfServiceRow.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-16)
        }

        // Section 2: 계정
        accountSectionView.snp.makeConstraints {
            $0.top.equalTo(infoSectionView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        logoutRow.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }

        deleteAccountButton.snp.makeConstraints {
            $0.top.equalTo(logoutRow.snp.bottom)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}

// MARK: - SettingsRowView

final class SettingsRowView: UIView {

    // MARK: - UI Components

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevronImageView = UIImageView()

    // MARK: - Properties

    private let hasChevron: Bool

    // MARK: - Initialization

    init(title: String, hasChevron: Bool, valueText: String? = nil) {
        self.hasChevron = hasChevron
        super.init(frame: .zero)
        style(title: title, valueText: valueText)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func updateValue(_ value: String) {
        valueLabel.text = value
        valueLabel.isHidden = false
    }
}

// MARK: - Setup

extension SettingsRowView {
    private func style(title: String, valueText: String?) {
        backgroundColor = .clear
        isUserInteractionEnabled = true

        titleLabel.do {
            $0.setTextWithTypography(title, style: .body14)
            $0.textColor = .neutral900
        }

        valueLabel.do {
            $0.setTextWithTypography(valueText ?? "", style: .label14)
            $0.textColor = .neutral600
            $0.isHidden = valueText == nil
        }

        chevronImageView.do {
            $0.image = .Icon.chevronRight
            $0.tintColor = .neutral600
            $0.contentMode = .scaleAspectFit
            $0.isHidden = !hasChevron
        }
    }

    private func layout() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(chevronImageView)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        valueLabel.snp.makeConstraints {
            $0.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }
    }
}

#if DEBUG
#Preview {
    GeneralSettingsView()
}
#endif
