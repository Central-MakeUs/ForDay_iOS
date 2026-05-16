//
//  HiddenHobbyCell.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import UIKit
import SnapKit
import Then

/// 숨겨진 취미 셀 (아이콘 + 이름 + + 버튼)
class HiddenHobbyCell: UITableViewCell {

    static let identifier = "HiddenHobbyCell"

    // UI Components
    private let hobbyIconView = UIImageView()
    private let hobbyNameLabel = UILabel()
    private let plusButton = UIButton()
    private let deleteButton = UIButton()

    // Callback
    var onPlusTapped: ((Int) -> Void)?
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

        hobbyIconView.do {
            $0.contentMode = .scaleAspectFit
        }

        hobbyNameLabel.do {
            $0.setTextWithTypography("", style: .body16)
            $0.textColor = .neutral800
        }

        plusButton.do {
            $0.setImage(.Icon.plusBlue, for: .normal)
            $0.tintColor = .systemBlue
            $0.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        }

        deleteButton.do {
            $0.setImage(.Icon.trash, for: .normal)
            $0.tintColor = .systemRed
            $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
            $0.isHidden = true
        }
    }

    private func setupLayout() {
        contentView.addSubview(hobbyIconView)
        contentView.addSubview(hobbyNameLabel)
        contentView.addSubview(plusButton)
        contentView.addSubview(deleteButton)

        hobbyIconView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        hobbyNameLabel.snp.makeConstraints {
            $0.leading.equalTo(hobbyIconView.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
        }

        plusButton.snp.makeConstraints {
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
        plusButton.isHidden = isDeletionMode
        deleteButton.isHidden = !isDeletionMode
    }

    // Actions

    @objc private func plusButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        onPlusTapped?(hobbyId)
    }

    @objc private func deleteButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        onDeleteTapped?(hobbyId)
    }
}
