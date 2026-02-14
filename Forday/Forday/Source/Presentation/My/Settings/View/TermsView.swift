//
//  TermsView.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit
import SnapKit
import Then

enum TermsType {
    case termsOfService
    case privacyPolicy

    var title: String {
        switch self {
        case .termsOfService:
            return "서비스 이용약관"
        case .privacyPolicy:
            return "개인정보 처리방침"
        }
    }
}

final class TermsView: UIView {

    // MARK: - UI Components

    // Custom Navigation Bar
    private let navigationBarView = UIView()
    private let titleLabel = UILabel()
    let closeButton = UIButton(type: .system)

    // Content
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private let contentContainerView = UIView()
    private let contentStackView = UIStackView()

    // Loading
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Properties

    private let termsType: TermsType

    // MARK: - Initialization

    init(termsType: TermsType) {
        self.termsType = termsType
        super.init(frame: .zero)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func updateTermsOfService(_ data: DTO.TermsOfServiceData) {
        loadingIndicator.stopAnimating()
        contentContainerView.isHidden = false

        // Clear existing content
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add title
        addTitleLabel(data.title)

        // Add version
        addVersionLabel(data.version)

        // Add sections
        for section in data.sections {
            addSectionView(section)
        }

        // Add service info (부칙)
        addServiceInfoView(data.serviceInfo)
    }

    func updatePrivacyPolicy(_ data: DTO.PrivacyPolicyData) {
        loadingIndicator.stopAnimating()
        contentContainerView.isHidden = false

        // Clear existing content
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add title
        addTitleLabel(data.title)

        // Add description if exists
        if let description = data.description {
            addDescriptionLabel(description)
        }

        // Add version
        addVersionLabel(data.version)

        // Add sections
        for section in data.sections {
            addSectionView(section)
        }

        // Add service info
        addServiceInfoView(data.serviceInfo)
    }

    func showLoading() {
        contentContainerView.isHidden = true
        loadingIndicator.startAnimating()
    }

    func showError(_ message: String) {
        loadingIndicator.stopAnimating()
        contentContainerView.isHidden = false

        // Clear existing content
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let errorLabel = UILabel()
        errorLabel.setTextWithTypography(message, style: .body14)
        errorLabel.textColor = .neutral600
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(errorLabel)
    }
}

// MARK: - Content Building

extension TermsView {
    private func addTitleLabel(_ title: String) {
        let label = UILabel()
        label.setTextWithTypography(title, style: .header16)
        label.textColor = .neutral900
        label.numberOfLines = 0
        contentStackView.addArrangedSubview(label)
        contentStackView.setCustomSpacing(8, after: label)
    }

    private func addVersionLabel(_ version: String) {
        let label = UILabel()
        label.setTextWithTypography(version, style: .label12)
        label.textColor = .neutral500
        contentStackView.addArrangedSubview(label)
        contentStackView.setCustomSpacing(24, after: label)
    }

    private func addDescriptionLabel(_ description: String) {
        let label = UILabel()
        label.setTextWithTypography(description, style: .body14)
        label.textColor = .neutral800
        label.numberOfLines = 0
        contentStackView.addArrangedSubview(label)
        contentStackView.setCustomSpacing(16, after: label)
    }

    private func addSectionView(_ section: DTO.TermsSection) {
        // Section header (e.g., "제1조 (목적)")
        let headerLabel = UILabel()
        headerLabel.setTextWithTypography("제\(section.sectionNo)조 (\(section.sectionTitle))", style: .label14)
        headerLabel.textColor = .neutral900
        headerLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(headerLabel)
        contentStackView.setCustomSpacing(8, after: headerLabel)

        // Articles
        for article in section.articles {
            addArticleView(article)
        }

        // Add spacing after section
        let spacer = UIView()
        spacer.snp.makeConstraints { $0.height.equalTo(16) }
        contentStackView.addArrangedSubview(spacer)
    }

    private func addArticleView(_ article: DTO.TermsArticle) {
        // Article content
        let contentText: String
        if let clauseNo = article.clauseNo {
            contentText = "\(clauseNo). \(article.content)"
        } else {
            contentText = article.content
        }

        let contentLabel = UILabel()
        contentLabel.setTextWithTypography(contentText, style: .body14)
        contentLabel.textColor = .neutral800
        contentLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(contentLabel)

        // Items
        if let items = article.items {
            for item in items {
                addItemView(item)
            }
        }

        contentStackView.setCustomSpacing(8, after: contentLabel)
    }

    private func addItemView(_ item: DTO.TermsItem) {
        let containerView = UIView()

        let itemLabel = UILabel()
        itemLabel.setTextWithTypography("\(item.itemNo)) \(item.content)", style: .body14)
        itemLabel.textColor = .neutral700
        itemLabel.numberOfLines = 0

        containerView.addSubview(itemLabel)
        itemLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview()
        }

        contentStackView.addArrangedSubview(containerView)
    }

    private func addServiceInfoView(_ serviceInfo: DTO.ServiceInfo) {
        // Divider
        let divider = UIView()
        divider.backgroundColor = .stroke001
        divider.snp.makeConstraints { $0.height.equalTo(1) }
        contentStackView.addArrangedSubview(divider)
        contentStackView.setCustomSpacing(16, after: divider)

        // Service info title (부칙)
        let titleLabel = UILabel()
        titleLabel.setTextWithTypography(serviceInfo.title, style: .label14)
        titleLabel.textColor = .neutral900
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.setCustomSpacing(8, after: titleLabel)

        // Description
        let descLabel = UILabel()
        descLabel.setTextWithTypography(serviceInfo.description, style: .body14)
        descLabel.textColor = .neutral800
        descLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(descLabel)
        contentStackView.setCustomSpacing(16, after: descLabel)

        // Service details
        let details = [
            ("서비스명", serviceInfo.serviceName),
            ("대표자명", serviceInfo.ceoName),
            ("주소", serviceInfo.address),
            ("이메일", serviceInfo.email),
            ("시행일", serviceInfo.effectiveDate)
        ]

        for (label, value) in details {
            addServiceDetailRow(label: label, value: value)
        }

        // Privacy officer if exists
        if let privacyOfficer = serviceInfo.privacyOfficer {
            addServiceDetailRow(label: "개인정보 보호책임자", value: privacyOfficer)
        }
    }

    private func addServiceDetailRow(label: String, value: String) {
        let rowView = UIView()

        let labelText = UILabel()
        labelText.setTextWithTypography(label, style: .label12)
        labelText.textColor = .neutral500

        let valueText = UILabel()
        valueText.setTextWithTypography(value, style: .body12)
        valueText.textColor = .neutral800
        valueText.numberOfLines = 0

        rowView.addSubview(labelText)
        rowView.addSubview(valueText)

        labelText.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(100)
        }

        valueText.snp.makeConstraints {
            $0.leading.equalTo(labelText.snp.trailing).offset(8)
            $0.trailing.top.bottom.equalToSuperview()
        }

        contentStackView.addArrangedSubview(rowView)
        contentStackView.setCustomSpacing(8, after: rowView)
    }
}

// MARK: - Setup

extension TermsView {
    private func style() {
        backgroundColor = .bg002

        // Navigation Bar
        navigationBarView.do {
            $0.backgroundColor = .bg001
        }

        titleLabel.do {
            $0.setTextWithTypography(termsType.title, style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        closeButton.do {
            $0.setImage(.Icon.xmark, for: .normal)
            $0.tintColor = .neutral900
        }

        // Scroll View
        scrollView.do {
            $0.backgroundColor = .bg002
            $0.showsVerticalScrollIndicator = true
            $0.alwaysBounceVertical = true
        }

        scrollContentView.do {
            $0.backgroundColor = .bg002
        }

        // Content Container (white rounded)
        contentContainerView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 16
            $0.isHidden = true
        }

        // Content Stack View
        contentStackView.do {
            $0.axis = .vertical
            $0.spacing = 4
            $0.alignment = .fill
        }

        loadingIndicator.do {
            $0.color = .neutral600
            $0.hidesWhenStopped = true
        }
    }

    private func layout() {
        addSubview(navigationBarView)
        navigationBarView.addSubview(titleLabel)
        navigationBarView.addSubview(closeButton)

        addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(contentContainerView)
        contentContainerView.addSubview(contentStackView)

        addSubview(loadingIndicator)

        // Navigation Bar Layout
        navigationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(44)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
        }

        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
            $0.width.height.equalTo(24)
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

        // Content Container Layout
        contentContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-32)
        }

        // Content Stack View Layout
        contentStackView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.trailing.bottom.equalToSuperview().offset(-16)
        }

        // Loading Indicator Layout
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

#if DEBUG
#Preview("Terms of Service") {
    TermsView(termsType: .termsOfService)
}

#Preview("Privacy Policy") {
    TermsView(termsType: .privacyPolicy)
}
#endif
