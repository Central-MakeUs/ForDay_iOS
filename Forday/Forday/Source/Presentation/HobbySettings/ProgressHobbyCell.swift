//
//  ProgressHobbyCell.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import UIKit
import SnapKit
import Then

/// 활성화된 취미 셀 (드래그 핸들 + 아이콘 + 이름 + - 버튼)
class ProgressHobbyCell: UITableViewCell {

    static let identifier = "ProgressHobbyCell"

    // UI Components
    private let menuIconView = UIImageView()
    private let hobbyIconView = UIImageView()
    private let hobbyNameLabel = UILabel()
    private let minusButton = UIButton()
    private let deleteButton = UIButton()

    // Callback
    var onMinusTapped: ((Int) -> Void)?
    var onDeleteTapped: ((Int) -> Void)?

    // Hobby ID
    private var hobbyId: Int?

    // Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStyle()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup

    private func setupStyle() {
        selectionStyle = .none
        backgroundColor = .clear

        menuIconView.do {
            $0.image = .Icon.threeLines
            $0.tintColor = .neutral800
            $0.contentMode = .scaleAspectFit
        }

        hobbyIconView.do {
            $0.contentMode = .scaleAspectFit
        }

        hobbyNameLabel.do {
            $0.setTextWithTypography("", style: .body16)
            $0.textColor = .neutral800
        }

        minusButton.do {
            $0.setImage(.Icon.minusRed, for: .normal)
            $0.tintColor = .systemRed
            $0.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
        }

        deleteButton.do {
            $0.setImage(.Icon.trash, for: .normal)
            $0.tintColor = .systemRed
            $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
            $0.isHidden = true
        }
    }

    private func setupLayout() {
        contentView.addSubview(menuIconView)
        contentView.addSubview(hobbyIconView)
        contentView.addSubview(hobbyNameLabel)
        contentView.addSubview(minusButton)
        contentView.addSubview(deleteButton)

        menuIconView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        hobbyIconView.snp.makeConstraints {
            $0.leading.equalTo(menuIconView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        hobbyNameLabel.snp.makeConstraints {
            $0.leading.equalTo(hobbyIconView.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
        }

        minusButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        contentView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview()
        }
    }

    // Configure

    func configure(hobby: HobbyItemV2Entity, isDeletionMode: Bool = false) {
        self.hobbyId = hobby.hobbyId
        hobbyIconView.image = hobby.imageAsset.icon
        hobbyNameLabel.setTextWithTypography(hobby.hobbyName, style: .body16)

        // 삭제 모드에 따라 버튼 표시 전환
        minusButton.isHidden = isDeletionMode
        deleteButton.isHidden = !isDeletionMode
    }

    // Actions

    @objc private func minusButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        onMinusTapped?(hobbyId)
    }

    @objc private func deleteButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        onDeleteTapped?(hobbyId)
    }
}
