//
//  NewHobbySettingsViewController.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//

import UIKit
import SnapKit
import Then

/// 새로운 취미설정 화면 (빈 뷰 - 추후 구현 예정)
class NewHobbySettingsViewController: UIViewController {

    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // UI Components
    private let placeholderLabel = UILabel()

    // Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        style()
        layout()
    }

    // Setup

    private func setupNavigationBar() {
        title = "취미 설정"
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func style() {
        view.backgroundColor = .systemBackground

        placeholderLabel.do {
            $0.text = "새로운 취미설정 화면\n(추후 구현 예정)"
            $0.font = .systemFont(ofSize: 18, weight: .medium)
            $0.textColor = .neutral600
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
    }

    private func layout() {
        view.addSubview(placeholderLabel)

        placeholderLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
