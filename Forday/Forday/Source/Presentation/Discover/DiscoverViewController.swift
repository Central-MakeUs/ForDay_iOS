//
//  DiscoverViewController.swift
//  Forday
//
//  Created by Subeen on 2/26/26.
//


import UIKit
import SnapKit
import Then

class DiscoverViewController: UIViewController {

    // MARK: - UI Components

    private let containerView = UIView().then {
        $0.backgroundColor = .neutralWhite
    }

    private let iconImageView = UIImageView().then {
        $0.image = .Icon.sorry
        $0.tintColor = .neutral400
        $0.contentMode = .scaleAspectFit
    }

    private let titleLabel = UILabel().then {
        $0.text = "서비스 준비 중이에요"
        $0.textColor = .neutral900
        $0.textAlignment = .center
        $0.applyTypography(.header14)
    }

    private let descriptionLabel = UILabel().then {
        $0.text = "더 나은 서비스로 곧 찾아올게요!"
        $0.textColor = .neutral500
        $0.textAlignment = .center
        $0.applyTypography(.body12)
    }

    // MARK: - Properties

    weak var coordinator: MainTabBarCoordinator?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Style & Layout

extension DiscoverViewController {

    private func style() {
        view.backgroundColor = .neutralWhite
    }

    private func layout() {
        view.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.size.equalTo(60)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
