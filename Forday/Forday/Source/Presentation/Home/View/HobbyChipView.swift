//
//  HobbyChipView.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//

import UIKit
import SnapKit
import Then

/// 취미 목록에서 사용하는 Chip 뷰
class HobbyChipView: UIButton {

    // Properties

    var hobbyId: Int?
    var isSelectedChip: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    // Initialization

    init(hobbyName: String, hobbyId: Int, isSelected: Bool = false) {
        super.init(frame: .zero)
        self.hobbyId = hobbyId
        self.isSelectedChip = isSelected
        style()
        setTitle(hobbyName)
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup

    private func style() {
        layer.cornerRadius = 18
        clipsToBounds = true

        // Figma 디자인과 일치하도록 Typography의 수직 패딩 추가
        let typography = TypographyStyle.body14
        let verticalInset = 6 + typography.topPadding
        contentEdgeInsets = UIEdgeInsets(
            top: verticalInset,
            left: 12,
            bottom: verticalInset,
            right: 12
        )
    }

    private func setTitle(_ title: String) {
        // Typography 스타일을 attributed string으로 적용
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttributes(
            TypographyStyle.body14.attributes,
            range: NSRange(location: 0, length: title.utf16.count)
        )
        setAttributedTitle(attributedString, for: .normal)
    }

    private func updateAppearance() {
        if isSelectedChip {
            // 선택된 상태: 주황색 배경, 흰색 텍스트
            backgroundColor = .action001
            setTitleColor(.neutralWhite, for: .normal)
            layer.borderWidth = 0
        } else {
            // 비선택 상태: 흰색 배경, 회색 테두리, 회색 텍스트
            backgroundColor = .neutralWhite
            setTitleColor(.neutral800, for: .normal)
            layer.borderColor = UIColor.stroke001.cgColor
            layer.borderWidth = 1
        }
    }
}
