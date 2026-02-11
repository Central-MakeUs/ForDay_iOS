//
//  StickerItemView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class StickerItemView: UIView {

    // MARK: - UI Components

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemGray4
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Configuration

    func configure(with state: StickerState) {

        switch state {
        case .empty:
            // 회색 빈 스티커
            imageView.image = .My.empty

        case .todayHighlight:
            // 핑크 외곽선 스티커 (오늘 기록 안 함)
            imageView.image = .My.todayEmpty

        case .filled(let stickerFileName):
            // Convert filename to StickerType and load actual image
            if let stickerType = StickerType(fileName: stickerFileName) {
                imageView.image = stickerType.image
            } else {
                // Fallback for unknown sticker types
                imageView.image = UIImage(systemName: "circle.fill")
                imageView.tintColor = .systemGray
            }
        }
    }

    // MARK: - Sticker State

    enum StickerState {
        case empty                      // 회색 빈 스티커
        case todayHighlight             // 핑크 외곽선 (오늘 기록 가능)
        case filled(String)             // 채워진 스티커 (파일명)
    }
}

