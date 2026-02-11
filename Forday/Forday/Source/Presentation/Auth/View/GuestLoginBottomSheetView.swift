//
//  GuestLoginBottomSheetView.swift
//  Forday
//
//  Created by Subeen on 2/4/26.
//

import UIKit
import SnapKit
import Then

final class GuestLoginBottomSheetView: UIView {

    // MARK: - UI Components

    private let characterImageView = UIImageView()
    private let welcomeTitleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let hintBubbleView = UIView()
    private let hintLabel = UILabel()
    private let hintTriangleView = UIView()

    let kakaoLoginButton = UIButton()
    let appleLoginButton = UIButton()

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

extension GuestLoginBottomSheetView {
    private func style() {
        backgroundColor = .neutralWhite
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // Character
        characterImageView.do {
            $0.image = .My.main
            $0.contentMode = .scaleAspectFit
        }

        // Welcome Title
        welcomeTitleLabel.do {
            $0.setTextWithTypography("포데이에\n오신 것을 환영합니다!", style: .header24)
            $0.textColor = .neutral900
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        // Subtitle
        subtitleLabel.do {
            $0.setTextWithTypography("당신만의 취미 루틴, AI가 추천해드립니다", style: .label14)
            $0.textColor = .secondary003
            $0.textAlignment = .center
        }

        // Hint Bubble
        hintBubbleView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 10
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowOffset = .zero
            $0.layer.shadowRadius = 10
        }

        hintLabel.do {
            $0.setTextWithTypography("SNS로 가볍게 시작하기!", style: .body12)
            $0.textColor = .neutral900
            $0.textAlignment = .center
        }

        hintTriangleView.do {
            $0.backgroundColor = .clear
        }

        // Kakao Button
        kakaoLoginButton.do {
            $0.backgroundColor = UIColor(hex: "FEE500")
            $0.layer.cornerRadius = 12

            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "message.fill")
            config.imagePlacement = .leading
            config.imagePadding = 10
            config.baseForegroundColor = .neutralBlack
            config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 40, bottom: 14, trailing: 40)

            let attributedTitle = NSAttributedString(
                string: "카카오톡으로 시작하기",
                attributes: TypographyStyle.header16.attributes.merging([.foregroundColor: UIColor.neutralBlack]) { _, new in new }
            )
            config.attributedTitle = AttributedString(attributedTitle)

            $0.configuration = config
        }

        // Apple Button
        appleLoginButton.do {
            $0.backgroundColor = .neutralBlack
            $0.layer.cornerRadius = 12

            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "apple.logo")
            config.imagePlacement = .leading
            config.imagePadding = 10
            config.baseForegroundColor = .neutralWhite
            config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 40, bottom: 14, trailing: 40)

            let attributedTitle = NSAttributedString(
                string: "Apple로 시작하기",
                attributes: TypographyStyle.header16.attributes.merging([.foregroundColor: UIColor.neutralWhite]) { _, new in new }
            )
            config.attributedTitle = AttributedString(attributedTitle)

            $0.configuration = config
        }
    }

    private func layout() {
        addSubview(characterImageView)
        addSubview(welcomeTitleLabel)
        addSubview(subtitleLabel)

        addSubview(hintBubbleView)
        hintBubbleView.addSubview(hintLabel)
        addSubview(hintTriangleView)

        addSubview(kakaoLoginButton)
        addSubview(appleLoginButton)

        // Character
        characterImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(40)
            $0.size.equalTo(56)
        }

        // Title
        welcomeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(characterImageView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(welcomeTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // Hint Bubble
        hintBubbleView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(kakaoLoginButton.snp.top).offset(-20)
        }

        hintLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        hintTriangleView.snp.makeConstraints {
            $0.centerX.equalTo(hintBubbleView)
            $0.top.equalTo(hintBubbleView.snp.bottom)
            $0.width.equalTo(10)
            $0.height.equalTo(4)
        }

        // Kakao Button
        kakaoLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            $0.bottom.equalTo(appleLoginButton.snp.top).offset(-12)
        }

        // Apple Button
        appleLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawTriangle()
    }

    private func drawTriangle() {
        let triangleLayer = CAShapeLayer()
        let path = UIBezierPath()

        let triangleWidth: CGFloat = 10
        let triangleHeight: CGFloat = 4

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: triangleWidth / 2, y: triangleHeight))
        path.addLine(to: CGPoint(x: triangleWidth, y: 0))
        path.close()

        triangleLayer.path = path.cgPath
        triangleLayer.fillColor = UIColor.neutralWhite.cgColor

        hintTriangleView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        hintTriangleView.layer.addSublayer(triangleLayer)
    }
}

#if DEBUG
#Preview {
    GuestLoginBottomSheetView()
}
#endif
