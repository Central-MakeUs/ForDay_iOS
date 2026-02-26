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

    private let checkboxContainer = UIView()
    private let checkboxLabel = UILabel()
    let checkboxImageView = UIImageView()

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
        titleLabel.setTextWithTypography("신고가 완료되었습니다.", style: .header18)
        checkboxLabel.setTextWithTypography("\(nickname) 님 차단하기", style: .body14)
    }

    func updateCheckboxState(isChecked: Bool) {
        checkboxImageView.image = isChecked ? .Onoff.checkboxTrue : .Onoff.checkboxFalse
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

        checkboxContainer.do {
            $0.backgroundColor = .clear
            $0.isUserInteractionEnabled = true
        }

        checkboxLabel.do {
            $0.textColor = .neutral800
        }

        checkboxImageView.do {
            $0.image = .Onoff.checkboxFalse
            $0.contentMode = .scaleAspectFit
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
        addSubview(checkboxContainer)
        checkboxContainer.addSubview(checkboxLabel)
        checkboxContainer.addSubview(checkboxImageView)
        addSubview(confirmButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.centerX.equalToSuperview()
        }

        checkboxContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }

        checkboxLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        checkboxImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
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
