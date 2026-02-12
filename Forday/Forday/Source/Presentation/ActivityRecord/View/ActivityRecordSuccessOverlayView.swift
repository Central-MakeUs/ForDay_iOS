//
//  ActivityRecordSuccessOverlayView.swift
//  Forday
//
//  Created by Subeen on 2/12/26.
//

import UIKit
import SnapKit
import Then
import Lottie

final class ActivityRecordSuccessOverlayView: UIView {

    // MARK: - Properties

    private let gradientView = UIView()
    private let containerView = UIView()

    private let lottieView: LottieAnimationView = {
        if let dataAsset = NSDataAsset(name: "lottie/successRecord"),
           let animation = try? LottieAnimation.from(data: dataAsset.data) {
            return LottieAnimationView(animation: animation)
        }
        return LottieAnimationView()
    }()

    private let messageLabel = UILabel()

    var onAnimationCompleted: (() -> Void)?

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

extension ActivityRecordSuccessOverlayView {
    private func style() {
        backgroundColor = .clear

        // Gradient background (white gradient from bottom)
        gradientView.do {
            $0.backgroundColor = .clear
        }

        // Lottie
        lottieView.do {
            $0.loopMode = .playOnce
            $0.contentMode = .scaleAspectFit
        }

        // Message
        messageLabel.do {
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.textColor = .neutral900
        }
    }

    private func layout() {
        addSubview(gradientView)
        addSubview(containerView)
        containerView.addSubview(lottieView)
        containerView.addSubview(messageLabel)

        gradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        lottieView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.size.equalTo(320)
        }

        messageLabel.snp.makeConstraints {
            $0.top.equalTo(lottieView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradient()
    }

    private func setupGradient() {
        // Remove existing gradient layers
        gradientView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.locations = [0.0, 0.64]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - Public Methods

extension ActivityRecordSuccessOverlayView {

    func configure(nickname: String) {
        let text = "수고했어요, \(nickname)님\n오늘의 포데이 완료!"
        messageLabel.setTextWithTypography(text, style: .header20)
        messageLabel.textAlignment = .center
    }

    func playAnimation() {
        lottieView.play { [weak self] finished in
            if finished {
                self?.fadeOutAndComplete()
            }
        }
    }

    private func fadeOutAndComplete() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            self.onAnimationCompleted?()
        }
    }

    func show(in parentView: UIView) {
        alpha = 0
        parentView.addSubview(self)
        snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        } completion: { _ in
            self.playAnimation()
        }
    }
}

#Preview {
    let view = ActivityRecordSuccessOverlayView()
    view.configure(nickname: "유지")
    return view
}
