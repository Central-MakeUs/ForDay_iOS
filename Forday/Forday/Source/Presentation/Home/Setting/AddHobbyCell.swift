//
//  AddHobbyCell.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import UIKit
import SnapKit
import Then

class AddHobbyCell: UITableViewCell {

    static let identifier = "AddHobbyCell"

    // UI Components
    private let containerView = UIView()
    private let contentStackView = UIStackView()
    private let plusIconView = UIImageView()
    private let titleLabel = UILabel()
    private let chevronIconView = UIImageView()

    // Callback
    var onTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        // Container
        containerView.do {
            $0.backgroundColor = .systemBackground
            $0.layer.cornerRadius = 12
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.05
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 4
        }

        // Stack View
        contentStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }

        // Plus Icon
        plusIconView.do {
            $0.image = UIImage(systemName: "plus.circle")
            $0.tintColor = .neutral600
            $0.contentMode = .scaleAspectFit
        }

        // Title
        titleLabel.do {
            $0.text = "취미 추가하기"
            $0.applyTypography(.body14)
            $0.textColor = .neutral700
        }

        // Chevron
        chevronIconView.do {
            $0.image = UIImage(systemName: "chevron.right")
            $0.tintColor = .neutral400
            $0.contentMode = .scaleAspectFit
        }

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        containerView.addGestureRecognizer(tapGesture)

        // Layout
        contentStackView.addArrangedSubview(plusIconView)
        contentStackView.addArrangedSubview(titleLabel)

        contentView.addSubview(containerView)
        containerView.addSubview(contentStackView)
        containerView.addSubview(chevronIconView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            $0.height.equalTo(60)
        }

        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        plusIconView.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }

        chevronIconView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(8)
            $0.height.equalTo(14)
        }
    }

    @objc private func cellTapped() {
        onTapped?()
    }
}
