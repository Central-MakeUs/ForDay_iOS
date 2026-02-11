//
//  FloatingActionMenu.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import UIKit
import SnapKit
import Then

class FloatingActionMenu: UIView {

    // MARK: - Properties

    enum ActionType {
        case addActivity
        case viewActivityList
    }

    private let containerView = UIView()
    private let stackView = UIStackView()
    private let addActivityButton = MenuItemView(
        iconImage: .Icon.plus,
        title: "활동 추가"
    )
    private let viewListButton = MenuItemView(
        iconImage: .Icon.storage,
        title: "활동 리스트"
    )

    var onActionSelected: ((ActionType) -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension FloatingActionMenu {
    private func style() {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 20)
        isHidden = true
        isUserInteractionEnabled = false

        containerView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 8
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 8
        }

        stackView.do {
            $0.axis = .vertical
            $0.spacing = 0
            $0.alignment = .fill
        }
    }

    private func layout() {
        addSubview(containerView)
        containerView.addSubview(stackView)

        stackView.addArrangedSubview(addActivityButton)
        stackView.addArrangedSubview(viewListButton)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupActions() {
        addActivityButton.onTap = { [weak self] in
            self?.onActionSelected?(.addActivity)
        }

        viewListButton.onTap = { [weak self] in
            self?.onActionSelected?(.viewActivityList)
        }
    }
}

// MARK: - Public Methods

extension FloatingActionMenu {
    func show(animated: Bool = true) {
        isHidden = false
        isUserInteractionEnabled = true

        let animations: () -> Void = { [weak self] in
            self?.alpha = 1
            self?.transform = .identity
        }

        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut,
                animations: animations
            )
        } else {
            animations()
        }
    }

    func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        let animations: () -> Void = { [weak self] in
            self?.alpha = 0
            self?.transform = CGAffineTransform(translationX: 0, y: 20)
        }

        let hideCompletion: (Bool) -> Void = { [weak self] _ in
            self?.isHidden = true
            self?.isUserInteractionEnabled = false
            completion?()
        }

        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseIn,
                animations: animations,
                completion: hideCompletion
            )
        } else {
            animations()
            hideCompletion(true)
        }
    }
}

// MARK: - MenuItemView

private class MenuItemView: UIView {

    // MARK: - Properties

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    var onTap: (() -> Void)?

    // MARK: - Initialization

    init(iconImage: UIImage?, title: String) {
        super.init(frame: .zero)
        iconImageView.image = iconImage
        titleLabel.text = title
        style()
        layout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func style() {
        backgroundColor = .clear

        iconImageView.do {
            $0.tintColor = .neutral900
            $0.contentMode = .scaleAspectFit
        }

        titleLabel.do {
            $0.setTextWithTypography(titleLabel.text ?? "", style: .body14)
            $0.textColor = .neutral900
        }
    }

    private func layout() {
        addSubview(iconImageView)
        addSubview(titleLabel)

        snp.makeConstraints {
            $0.height.equalTo(48)
        }

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        // 탭 피드백 애니메이션
        UIView.animate(
            withDuration: 0.1,
            animations: { [weak self] in
                self?.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            },
            completion: { [weak self] _ in
                UIView.animate(withDuration: 0.1) {
                    self?.transform = .identity
                }
                self?.onTap?()
            }
        )
    }
}
