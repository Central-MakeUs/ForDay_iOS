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
    private let contentLabel = UILabel()

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

    func updateContent(_ content: String) {
        loadingIndicator.stopAnimating()
        contentLabel.setTextWithTypography(content, style: .body14)
        contentLabel.isHidden = false
    }

    func showLoading() {
        contentLabel.isHidden = true
        loadingIndicator.startAnimating()
    }

    func showError(_ message: String) {
        loadingIndicator.stopAnimating()
        contentLabel.setTextWithTypography(message, style: .body14)
        contentLabel.textColor = .neutral600
        contentLabel.isHidden = false
    }
}

// MARK: - Setup

extension TermsView {
    private func style() {
        backgroundColor = .bg001

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
            $0.backgroundColor = .bg001
            $0.showsVerticalScrollIndicator = true
            $0.alwaysBounceVertical = true
        }

        contentLabel.do {
            $0.textColor = .neutral800
            $0.numberOfLines = 0
            $0.isHidden = true
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
        scrollView.addSubview(contentLabel)

        addSubview(loadingIndicator)

        // Navigation Bar Layout
        navigationBarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        // Scroll View Layout
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.width.equalTo(scrollView).offset(-40)
        }

        // Loading Indicator Layout
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

#if DEBUG
#Preview("Terms of Service") {
    let view = TermsView(termsType: .termsOfService)
    view.updateContent("서비스 이용약관 내용이 여기에 표시됩니다.\n\n제1조 (목적)\n이 약관은 ForDay 서비스 이용에 관한 조건을 규정합니다.")
    return view
}

#Preview("Privacy Policy") {
    let view = TermsView(termsType: .privacyPolicy)
    view.updateContent("개인정보 처리방침 내용이 여기에 표시됩니다.\n\n제1조 (개인정보의 수집)\n회사는 서비스 제공을 위해 필요한 최소한의 개인정보를 수집합니다.")
    return view
}
#endif
