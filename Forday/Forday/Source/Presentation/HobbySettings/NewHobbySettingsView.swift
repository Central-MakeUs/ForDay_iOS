//
//  NewHobbySettingsView.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import UIKit
import SnapKit
import Then

class NewHobbySettingsView: UIView {

    // UI Components

    // Header
    let backButton = UIButton()
    private let titleLabel = UILabel()
    let trashButton = UIButton()
    let plusButton = UIButton()
    let closeButton = UIButton()

    // Description
    private let descriptionLabel = UILabel()

    // TableView
    let tableView = UITableView()

    // Bottom Save Button
    let saveButton = UIButton()
    private let saveButtonGradientView = UIView()

    // Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Style

    private func style() {
        backgroundColor = .systemBackground

        // Header
        backButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral800
        }

        titleLabel.do {
            $0.setTextWithTypography("취미 설정", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        trashButton.do {
            $0.setImage(.Icon.trash, for: .normal)
            $0.tintColor = .neutral800
        }

        plusButton.do {
            $0.setImage(.Icon.plus, for: .normal)
            $0.tintColor = .neutral800
        }

        closeButton.do {
            $0.setImage(.Icon.xmark, for: .normal)
            $0.tintColor = .neutral800
            $0.isHidden = true
        }

        // Description
        descriptionLabel.do {
            $0.setTextWithTypography(
                "취미는 + - 버튼을 눌러 최대 10개 까지 추가할 수 있어요.\n꾹 눌러서 이동하면 노출 순서를 변경할 수 있어요.",
                style: .label14
            )
            $0.textColor = .neutral800
            $0.numberOfLines = 0
        }

        // TableView
        tableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.showsVerticalScrollIndicator = false
            $0.dragInteractionEnabled = true
            $0.register(ProgressHobbyCell.self, forCellReuseIdentifier: ProgressHobbyCell.identifier)
            $0.register(HiddenHobbyCell.self, forCellReuseIdentifier: HiddenHobbyCell.identifier)
        }

        // Save Button
        saveButtonGradientView.do {
            $0.backgroundColor = .white
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.08
            $0.layer.shadowOffset = CGSize(width: 0, height: -2)
            $0.layer.shadowRadius = 8
        }

        saveButton.do {
            $0.setTitleWithTypography("저장", style: .header16)
            $0.backgroundColor = .action001
            $0.setTitleColor(.neutralWhite, for: .normal)
            $0.setTitleColor(.neutralWhite.withAlphaComponent(0.5), for: .disabled)
            $0.layer.cornerRadius = 12
            $0.isEnabled = false
        }
    }

    // Layout

    private func layout() {
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(trashButton)
        addSubview(plusButton)
        addSubview(closeButton)
        addSubview(descriptionLabel)
        addSubview(tableView)
        addSubview(saveButtonGradientView)
        saveButtonGradientView.addSubview(saveButton)

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }

        plusButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(backButton)
            $0.width.height.equalTo(24)
        }

        trashButton.snp.makeConstraints {
            $0.trailing.equalTo(plusButton.snp.leading).offset(-12)
            $0.centerY.equalTo(backButton)
            $0.width.height.equalTo(24)
        }

        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(backButton)
            $0.width.height.equalTo(24)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(saveButtonGradientView.snp.top)
        }

        saveButtonGradientView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(88)
        }

        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
        }
    }

    // Public Methods

    func updateSaveButtonState(isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
        saveButton.backgroundColor = isEnabled ? .action001 : .neutral200
    }

    func updateNavigationForDeletionMode(isDeletionMode: Bool) {
        if isDeletionMode {
            // 삭제 모드: trash, plus 숨기고 closeButton 표시
            trashButton.isHidden = true
            plusButton.isHidden = true
            closeButton.isHidden = false
        } else {
            // 기본 모드: trash, plus 표시하고 closeButton 숨기기
            trashButton.isHidden = false
            plusButton.isHidden = false
            closeButton.isHidden = true
        }
    }
}
