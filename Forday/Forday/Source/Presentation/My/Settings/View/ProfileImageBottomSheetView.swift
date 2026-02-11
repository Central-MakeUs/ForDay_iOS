//
//  ProfileImageBottomSheetView.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit
import SnapKit
import Then

final class ProfileImageBottomSheetView: UIView {

    // MARK: - UI Components

    private let containerView = UIView()
    private let handleView = UIView()
    private let titleLabel = UILabel()

    let selectFromAlbumButton = UIButton(type: .system)
    let setDefaultImageButton = UIButton(type: .system)

    let confirmButton = UIButton(type: .system)

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

extension ProfileImageBottomSheetView {
    private func style() {
        backgroundColor = .neutralWhite

        containerView.do {
            $0.backgroundColor = .neutralWhite
        }

        handleView.do {
            $0.backgroundColor = .neutral200
            $0.layer.cornerRadius = 2.5
        }

        titleLabel.do {
            $0.setTextWithTypography("프로필 사진 설정", style: .header18)
            $0.textColor = .neutral900
        }

        selectFromAlbumButton.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.layer.cornerRadius = 12

            $0.setTitle("앨범에서 사진 선택", for: .normal)
            $0.setTitleColor(.neutral800, for: .normal)
            $0.titleLabel?.font = TypographyStyle.body14.font
            $0.contentHorizontalAlignment = .left
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        setDefaultImageButton.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.layer.cornerRadius = 12

            $0.setTitle("기본 이미지로 설정", for: .normal)
            $0.setTitleColor(.neutral800, for: .normal)
            $0.titleLabel?.font = TypographyStyle.body14.font
            $0.contentHorizontalAlignment = .left
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        confirmButton.do {
            $0.backgroundColor = .action001
            $0.layer.cornerRadius = 12

            $0.setTitle("설정완료", for: .normal)
            $0.setTitleColor(.neutralWhite, for: .normal)
            $0.titleLabel?.font = TypographyStyle.header16.font
        }
    }

    private func layout() {
        addSubview(containerView)
        containerView.addSubview(handleView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(selectFromAlbumButton)
        containerView.addSubview(setDefaultImageButton)
        containerView.addSubview(confirmButton)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        handleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(5)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.leading.equalToSuperview().offset(20)
        }

        selectFromAlbumButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        }

        setDefaultImageButton.snp.makeConstraints {
            $0.top.equalTo(selectFromAlbumButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        }

        confirmButton.snp.makeConstraints {
            $0.top.equalTo(setDefaultImageButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
        }
    }
}

#if DEBUG
#Preview {
    ProfileImageBottomSheetView()
}
#endif
