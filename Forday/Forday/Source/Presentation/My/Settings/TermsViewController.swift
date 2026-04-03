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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = TermsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        loadContent()
    }
}

// MARK: - Setup

extension TermsViewController {
    private func setupNavigationBar() {
        title = termsType.title
        navigationController?.navigationBar.tintColor = .neutral900
    }
}

// MARK: - Data Loading

extension TermsViewController {
    private func loadContent() {
        termsView.showLoading()

        Task { [weak self] in
            guard let self = self else { return }
            do {
                switch self.termsType {
                case .termsOfService:
                    let data = try await self.termsService.fetchTermsOfService()
                    await MainActor.run { [weak self] in
                        self?.termsView.updateTermsOfService(data)
                    }
                case .privacyPolicy:
                    let data = try await self.termsService.fetchPrivacyPolicy()
                    await MainActor.run { [weak self] in
                        self?.termsView.updatePrivacyPolicy(data)
                    }
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.termsView.showError("내용을 불러오는데 실패했습니다.\n다시 시도해주세요.")
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
