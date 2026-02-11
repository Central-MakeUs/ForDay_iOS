//
//  FloatingActionButton.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import UIKit
import SnapKit
import Then

class FloatingActionButton: UIView {

    // MARK: - Properties

    private let button = UIButton()
    private let iconImageView = UIImageView()

    var isExpanded: Bool = false {
        didSet {
            updateButtonState(animated: true)
        }
    }

    var onTap: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension FloatingActionButton {
    private func style() {
        button.do {
            $0.backgroundColor = .neutral900
            $0.layer.cornerRadius = 28 // 56 / 2
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.15
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            $0.layer.shadowRadius = 8
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }

        iconImageView.do {
            $0.image = .Icon.plus
            $0.tintColor = .neutralWhite
            $0.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = false
        }
    }

    private func layout() {
        addSubview(button)
        button.addSubview(iconImageView)

        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.height.equalTo(56)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24)
        }
    }
}

// MARK: - Actions

extension FloatingActionButton {
    @objc private func buttonTapped() {
        onTap?()
    }

    private func updateButtonState(animated: Bool) {
        let rotation: CGFloat = isExpanded ? .pi / 4 : 0 // 45도 회전

        let animations: () -> Void = { [weak self] in
            self?.iconImageView.transform = CGAffineTransform(rotationAngle: rotation)
        }

        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut,
                animations: animations
            )
        } else {
            animations()
        }
    }
}
