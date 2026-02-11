//
//  TermsViewController.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit

final class TermsViewController: UIViewController {

    // MARK: - Properties

    private let termsType: TermsType
    private let termsService = TermsService()

    private var termsView: TermsView {
        return view as! TermsView
    }

    // MARK: - Initialization

    init(termsType: TermsType) {
        self.termsType = termsType
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = TermsView(termsType: termsType)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        loadContent()
    }
}

// MARK: - Setup

extension TermsViewController {
    private func setupActions() {
        termsView.closeButton.addTarget(
            self,
            action: #selector(dismissButtonTapped),
            for: .touchUpInside
        )
    }
}

// MARK: - Actions

extension TermsViewController {
    @objc private func dismissButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Data Loading

extension TermsViewController {
    private func loadContent() {
        termsView.showLoading()

        Task {
            do {
                let content: String

                switch termsType {
                case .termsOfService:
                    content = try await termsService.fetchTermsOfService()
                case .privacyPolicy:
                    content = try await termsService.fetchPrivacyPolicy()
                }

                await MainActor.run {
                    termsView.updateContent(content)
                }
            } catch {
                await MainActor.run {
                    termsView.showError("내용을 불러오는데 실패했습니다.\n다시 시도해주세요.")
                    print("❌ Failed to load terms: \(error)")
                }
            }
        }
    }
}

#if DEBUG
#Preview("Terms of Service") {
    TermsViewController(termsType: .termsOfService)
}

#Preview("Privacy Policy") {
    TermsViewController(termsType: .privacyPolicy)
}
#endif
