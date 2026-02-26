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
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .neutralWhite
            config.baseForegroundColor = .neutral800
            config.background.cornerRadius = 12
            config.background.strokeWidth = 1
            config.background.strokeColor = .stroke001
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

            var titleAttr = AttributedString("앨범에서 사진 선택")
            titleAttr.font = TypographyStyle.body14.font
            config.attributedTitle = titleAttr

            $0.configuration = config
            $0.contentHorizontalAlignment = .left
        }

        cameraButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .neutralWhite
            config.baseForegroundColor = .neutral800
            config.background.cornerRadius = 12
            config.background.strokeWidth = 1
            config.background.strokeColor = .stroke001
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

            var titleAttr = AttributedString("직접 촬영")
            titleAttr.font = TypographyStyle.body14.font
            config.attributedTitle = titleAttr

            $0.configuration = config
            $0.contentHorizontalAlignment = .left
        }
    }

    private func layout() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(albumButton)
        containerView.addSubview(cameraButton)

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
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-24)
        }
    }
}

#if DEBUG
#Preview {
    PhotoAddBottomSheetView()
}
#endif
