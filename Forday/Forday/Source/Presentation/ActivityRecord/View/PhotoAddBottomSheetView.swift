//
//  PhotoAddBottomSheetView.swift
//  Forday
//
//  Created by Subeen on 2/14/26.
//

import UIKit
import SnapKit
import Then

final class PhotoAddBottomSheetView: UIView {

    // MARK: - UI Components

    private let containerView = UIView()
    private let titleLabel = UILabel()
    let albumButton = UIButton(type: .system)
    let cameraButton = UIButton(type: .system)
    private let indicatorView = UIView()

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

extension PhotoAddBottomSheetView {
    private func style() {
        backgroundColor = .neutralWhite
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true

        titleLabel.do {
            $0.setTextWithTypography("사진 추가", style: .header18)
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }

        albumButton.do {
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

        cameraButton.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.layer.cornerRadius = 12

            $0.setTitle("직접 촬영", for: .normal)
            $0.setTitleColor(.neutral800, for: .normal)
            $0.titleLabel?.font = TypographyStyle.body14.font
            $0.contentHorizontalAlignment = .left
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        indicatorView.do {
            $0.backgroundColor = UIColor(hex: "#222222")
            $0.layer.cornerRadius = 2.5
        }
    }

    private func layout() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(albumButton)
        containerView.addSubview(cameraButton)
        containerView.addSubview(indicatorView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.leading.equalToSuperview().offset(20)
        }

        albumButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        }

        cameraButton.snp.makeConstraints {
            $0.top.equalTo(albumButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        }

        indicatorView.snp.makeConstraints {
            $0.top.equalTo(cameraButton.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(135)
            $0.height.equalTo(5)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-8)
        }
    }
}

#if DEBUG
#Preview {
    PhotoAddBottomSheetView()
}
#endif
