//
//  HobbyCardStackView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

enum SwipeDirection {
    case left
    case right
}

final class HobbyCardStackView: UIView {

    // MARK: - Properties

    private var cards: [CompletedHobbyCard] = []
    private var currentIndex: Int = 0

    private let topCardView = HobbyCardItemView()
    private let bottomCardView = HobbyCardItemView()

    private var topCardInitialCenter: CGPoint = .zero
    private var panGestureRecognizer: UIPanGestureRecognizer!

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with cards: [CompletedHobbyCard]) {
        guard !cards.isEmpty else { return }

        self.cards = cards
        self.currentIndex = 0

        loadCards()
    }

    // MARK: - Private Methods

    private func loadCards() {
        guard !cards.isEmpty else { return }

        // Configure top card
        let currentCard = cards[currentIndex]
        topCardView.configure(with: currentCard)
        topCardView.transform = .identity

        // Configure bottom card
        let nextIndex = (currentIndex + 1) % cards.count
        let nextCard = cards[nextIndex]
        bottomCardView.configure(with: nextCard)

        // Rotate bottom card slightly left
        let angle: CGFloat = -5 * .pi / 180 // -5 degrees
        bottomCardView.transform = CGAffineTransform(rotationAngle: angle)
    }

    private func animateSwipe(direction: SwipeDirection) {
        let targetX: CGFloat = direction == .right ? frame.width + 200 : -200

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.topCardView.center.x = targetX
            self.topCardView.alpha = 0
        }) { _ in
            // Update index
            if direction == .left {
                self.currentIndex = (self.currentIndex + 1) % self.cards.count
            } else {
                self.currentIndex = self.currentIndex == 0 ? self.cards.count - 1 : self.currentIndex - 1
            }

            // Swap cards
            self.swapCards()
        }
    }

    private func swapCards() {
        // Move bottom card to top with animation
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.bottomCardView.transform = .identity
        }) { _ in
            // Swap references
            let temp = self.topCardView
            temp.removeFromSuperview()

            // Bottom becomes top
            self.insertSubview(self.topCardView, at: 0)
            self.bringSubviewToFront(self.bottomCardView)

            // Reset top card
            self.topCardView.center = self.topCardInitialCenter
            self.topCardView.alpha = 1

            // Load new cards
            self.loadCards()
        }
    }

    private func animateReturn() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.topCardView.center = self.topCardInitialCenter
            self.topCardView.transform = .identity
        }
    }
}

// MARK: - Setup

extension HobbyCardStackView {
    private func style() {
        backgroundColor = .clear
    }

    private func layout() {
        addSubview(bottomCardView)
        addSubview(topCardView)

        bottomCardView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.equalTo(bottomCardView.snp.width).multipliedBy(1.5)
        }

        topCardView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(topCardView.snp.width).multipliedBy(1.5)
        }
    }

    private func setupGesture() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        topCardView.addGestureRecognizer(panGestureRecognizer)
        topCardView.isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topCardInitialCenter = topCardView.center
    }
}

// MARK: - Gesture Handling

extension HobbyCardStackView {
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)

        switch gesture.state {
        case .changed:
            // Move card with finger
            topCardView.center.x = topCardInitialCenter.x + translation.x

            // Optional: Add slight rotation based on translation
            let rotationAngle = translation.x / frame.width * 0.2
            topCardView.transform = CGAffineTransform(rotationAngle: rotationAngle)

        case .ended:
            // Check if swipe threshold is met
            let swipeThreshold: CGFloat = 100
            let velocityThreshold: CGFloat = 500

            if abs(velocity.x) > velocityThreshold || abs(translation.x) > swipeThreshold {
                // Swipe detected
                let direction: SwipeDirection = translation.x > 0 ? .right : .left
                animateSwipe(direction: direction)
            } else {
                // Return to original position
                animateReturn()
            }

        default:
            break
        }
    }
}

#Preview {
    HobbyCardStackView()
}
