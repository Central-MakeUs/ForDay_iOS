//
//  SkeletonView.swift
//  Forday
//
//  Created by Subeen on 2/11/26.
//

import UIKit
import Then

final class SkeletonView: UIView {

    // MARK: - Properties

    private let gradientLayer = CAGradientLayer()
    private var isAnimating = false

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(
            x: -bounds.width,
            y: 0,
            width: bounds.width * 3,
            height: bounds.height
        )
    }
}

// MARK: - Setup

extension SkeletonView {
    private func style() {
        backgroundColor = .neutral100
        layer.cornerRadius = 4
        clipsToBounds = true

        gradientLayer.do {
            $0.colors = [
                UIColor.neutral100.cgColor,
                UIColor.neutral50.cgColor,
                UIColor.neutral100.cgColor
            ]
            $0.locations = [0, 0.5, 1]
            $0.startPoint = CGPoint(x: 0, y: 0.5)
            $0.endPoint = CGPoint(x: 1, y: 0.5)
        }
        layer.addSublayer(gradientLayer)
    }
}

// MARK: - Public Methods

extension SkeletonView {
    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.2
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }

    func stopAnimating() {
        isAnimating = false
        gradientLayer.removeAnimation(forKey: "shimmer")
    }
}
