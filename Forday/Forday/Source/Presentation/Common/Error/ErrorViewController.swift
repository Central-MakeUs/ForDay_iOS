//
//  ErrorViewController.swift
//  Forday
//
//  Created by Subeen on 4/11/26.
//

import UIKit
import SnapKit
import Then

final class ErrorViewController: UIViewController {

    // MARK: - Properties

    private let iconImage: UIImage
    private let titleText: String
    private let messageText: String

    // MARK: - UI Components

    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let messageContainer = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let backButton = UIButton(type: .system)

    // MARK: - Initialization

    init(icon: UIImage, title: String, message: String) {
        self.iconImage = icon
        self.titleText = title
        self.messageText = message
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
        setupAction()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupStyle() {
        view.backgroundColor = .bg001

        iconImageView.do {
            $0.image = iconImage
            $0.contentMode = .scaleAspectFit
        }

        titleLabel.do {
            $0.text = titleText
            $0.font = TypographyStyle.header16.font
            $0.textColor = .neutral900
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        messageLabel.do {
            $0.text = messageText
            $0.font = TypographyStyle.label14.font
            $0.textColor = .neutral600
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        backButton.do {
            $0.setTitle("뒤로 가기", for: .normal)
            $0.titleLabel?.font = TypographyStyle.label12.font
            $0.setTitleColor(.neutralWhite, for: .normal)
            $0.backgroundColor = .neutral900
            $0.layer.cornerRadius = 6
            $0.clipsToBounds = true
        }
    }

    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(messageContainer)
        containerView.addSubview(backButton)

        messageContainer.addSubview(titleLabel)
        messageContainer.addSubview(messageLabel)

        // 컨테이너 - 중앙 정렬
        containerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // 아이콘 - 160x160
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.size.equalTo(160)
        }

        // 메시지 컨테이너
        messageContainer.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
        }

        // 타이틀
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        // 메시지
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        // 뒤로 가기 버튼
        backButton.snp.makeConstraints {
            $0.top.equalTo(messageContainer.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(28)
            $0.bottom.equalToSuperview()
        }
    }

    private func setupAction() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
