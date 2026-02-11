//
//  FlowLayoutView.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import UIKit
import SnapKit

class FlowLayoutView: UIView {

    // Properties

    private var buttons: [UIButton] = []
    private let spacing: CGFloat = 8
    private let horizontalInset: CGFloat = 20

    var onButtonTapped: ((String) -> Void)?

    // Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Public Methods

    func configure(with items: [String]) {
        // 기존 버튼 제거
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        // 새 버튼 생성
        for item in items {
            let button = createButton(title: item)
            addSubview(button)
            buttons.append(button)
        }

        layoutButtons()
    }

    private func createButton(title: String) -> UIButton {
        let button = UIButton()
        var config = UIButton.Configuration.plain()

        // Typography: label/12
        var attributedTitle = AttributedString(title)
        attributedTitle.font = UIFont(name: "Pretendard-Regular", size: 12)
        config.attributedTitle = attributedTitle

        config.baseForegroundColor = .neutral800
        config.background.backgroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)

        button.configuration = config

        // Shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.06
        button.clipsToBounds = false

        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        return button
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        if let title = sender.configuration?.title {
            onButtonTapped?(title)
        }
    }

    private func layoutButtons() {
        guard !buttons.isEmpty else { return }

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let maxWidth = bounds.width - (horizontalInset * 2)

        for button in buttons {
            let buttonSize = button.intrinsicContentSize

            // 현재 줄에 버튼을 추가할 공간이 없으면 다음 줄로
            if currentX + buttonSize.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += buttonSize.height + spacing
            }

            button.frame = CGRect(x: currentX, y: currentY, width: buttonSize.width, height: buttonSize.height)

            // Pill shape: cornerRadius = height / 2
            button.layer.cornerRadius = buttonSize.height / 2

            currentX += buttonSize.width + spacing
        }

        // 전체 높이 계산
        if let lastButton = buttons.last {
            let totalHeight = lastButton.frame.maxY
            snp.updateConstraints { $0.height.equalTo(totalHeight) }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }
}
