//
//  BlockUserBottomSheetView.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import UIKit
import SnapKit
import Then

final class BlockUserBottomSheetView: UIView {

    // MARK: - UI Components

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let checkboxContainer = UIView()
    let checkboxButton = UIButton()
    private let checkboxLabel = UILabel()

    let confirmButton = UIButton()

    private var nickname: String = ""

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(nickname: String) {
        self.nickname = nickname
        titleLabel.setTextWithTypography("신고가 접수되었습니다.", style: .header18)
        descriptionLabel.setTextWithTypography("해당 게시글은 검토 후 조치됩니다.", style: .body14)
        checkboxLabel.setTextWithTypography("\(nickname) 님 차단하기", style: .body14)
    }

    func updateCheckboxState(isChecked: Bool) {
        let imageName = isChecked ? "checkmark.square.fill" : "square"
        let image = UIImage(systemName: imageName)
        checkboxButton.setImage(image, for: .normal)
        checkboxButton.tintColor = isChecked ? .action001 : .neutral400
    }
}

// MARK: - Setup

extension BlockUserBottomSheetView {
    private func style() {
        backgroundColor = .neutralWhite

        titleLabel.do {
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }

        descriptionLabel.do {
            $0.textColor = .neutral600
            $0.textAlignment = .center
        }

        checkboxContainer.do {
            $0.backgroundColor = .neutral50
            $0.layer.cornerRadius = 12
        }

        checkboxButton.do {
            $0.setImage(UIImage(systemName: "square"), for: .normal)
            $0.tintColor = .neutral400
        }

        checkboxLabel.do {
            $0.textColor = .neutral800
        }

        confirmButton.do {
            $0.setTitle("완료", for: .normal)
            $0.setTitleColor(.neutralWhite, for: .normal)
            $0.backgroundColor = .action001
            $0.layer.cornerRadius = 12
            $0.titleLabel?.font = TypographyStyle.header16.font
        }
    }

    private func layout() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(checkboxContainer)
        checkboxContainer.addSubview(checkboxButton)
        checkboxContainer.addSubview(checkboxLabel)
        addSubview(confirmButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.centerX.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }

        checkboxContainer.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }

        checkboxButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        checkboxLabel.snp.makeConstraints {
            $0.leading.equalTo(checkboxButton.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }

        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(52)
        }
    }
}

#if DEBUG
#Preview {
    let view = BlockUserBottomSheetView()
    view.configure(nickname: "테스트닉네임")
    return view
}
#endif
