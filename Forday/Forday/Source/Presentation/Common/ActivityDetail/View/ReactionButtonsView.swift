//
//  ReactionButtonsView.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class ReactionButtonsView: UIView {

    // MARK: - UI Components

    private let awesomeButton = ReactionButton(type: .awesome)
    private let greatButton = ReactionButton(type: .great)
    private let amazingButton = ReactionButton(type: .amazing)
    private let fightingButton = ReactionButton(type: .fighting)
    private let bookmarkButton = UIButton()

    private let leftStackView = UIStackView()
    private let topBorder = UIView()

    // Tap events
    let reactionSingleTapped = PassthroughSubject<ReactionType, Never>()
    let reactionLongPressed = PassthroughSubject<ReactionType, Never>()
    let bookmarkTapped = PassthroughSubject<Void, Never>()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with detail: ActivityDetail) {
        // Configure reaction buttons
        awesomeButton.configure(
            isPressed: detail.userReaction.awesome,
            hasNewReaction: detail.newReaction.awesome
        )
        greatButton.configure(
            isPressed: detail.userReaction.great,
            hasNewReaction: detail.newReaction.great
        )
        amazingButton.configure(
            isPressed: detail.userReaction.amazing,
            hasNewReaction: detail.newReaction.amazing
        )
        fightingButton.configure(
            isPressed: detail.userReaction.fighting,
            hasNewReaction: detail.newReaction.fighting
        )

        // Configure bookmark button
        let bookmarkImage: UIImage = detail.scraped ? .Icon.bookmarkOn : .Icon.bookmarkOff
        bookmarkButton.setImage(bookmarkImage, for: .normal)
    }
}

// MARK: - Setup

extension ReactionButtonsView {
    private func style() {
        backgroundColor = .systemBackground

        topBorder.do {
            $0.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1) // #E5E5E5
        }

        leftStackView.do {
            $0.axis = .horizontal
            $0.spacing = 16
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }

        bookmarkButton.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .label
        }
    }

    private func layout() {
        addSubview(topBorder)
        addSubview(leftStackView)
        addSubview(bookmarkButton)

        topBorder.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        leftStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }

        bookmarkButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(leftStackView)
            $0.size.equalTo(24)
        }

        // Add components to left stack
        [awesomeButton, greatButton, amazingButton, fightingButton].forEach {
            leftStackView.addArrangedSubview($0)
            $0.snp.makeConstraints { make in
                make.size.equalTo(40)
            }
        }
    }

    private func setupActions() {
        setupGestureRecognizers(for: awesomeButton, type: .awesome)
        setupGestureRecognizers(for: greatButton, type: .great)
        setupGestureRecognizers(for: amazingButton, type: .amazing)
        setupGestureRecognizers(for: fightingButton, type: .fighting)

        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
    }

    private func setupGestureRecognizers(for button: UIButton, type: ReactionType) {
        // Single tap
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1

        // Long press
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5 // Default is 0.5s

        // Store reaction type in gesture recognizer
        singleTap.name = type.rawValue
        longPress.name = type.rawValue

        button.addGestureRecognizer(singleTap)
        button.addGestureRecognizer(longPress)
        button.isUserInteractionEnabled = true
    }

    @objc private func handleSingleTap(_ gesture: UITapGestureRecognizer) {
        guard let typeName = gesture.name,
              let type = ReactionType(rawValue: typeName) else { return }
        reactionSingleTapped.send(type)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let typeName = gesture.name,
              let type = ReactionType(rawValue: typeName) else { return }
        reactionLongPressed.send(type)
    }

    @objc private func bookmarkButtonTapped() {
        bookmarkTapped.send()
    }
}

// MARK: - Reaction Button

private final class ReactionButton: UIButton {

    private let reactionType: ReactionType
    private let iconImageView = UIImageView()
    private let newReactionDot = UIView()

    private var isPressed: Bool = false
    private var hasNewReaction: Bool = false

    init(type: ReactionType) {
        self.reactionType = type
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        // Background
        backgroundColor = .bg002
        layer.cornerRadius = 20
        clipsToBounds = false

        // Icon
        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.image = reactionType.icon
            $0.isUserInteractionEnabled = false
        }

        addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(22)
        }

        // New reaction dot
        newReactionDot.do {
            $0.backgroundColor = .secondary003
            $0.layer.cornerRadius = 3
            $0.isHidden = true
        }

        addSubview(newReactionDot)
        newReactionDot.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)  // 오른쪽에서 안쪽으로 2pt
            $0.top.equalToSuperview().offset(10)  // 위에서 아래로 2pt
            $0.size.equalTo(4)
        }
    }

    func configure(isPressed: Bool, hasNewReaction: Bool) {
        self.isPressed = isPressed
        self.hasNewReaction = hasNewReaction

        updateAppearance()
    }

    private func updateAppearance() {
        // Border style
        layer.borderWidth = isPressed ? 1 : 0
        layer.borderColor = isPressed ? UIColor.action001.cgColor : nil
        layer.backgroundColor = isPressed ? UIColor.primary002.cgColor : UIColor.bg002.cgColor

        // New reaction dot
        newReactionDot.isHidden = !hasNewReaction
    }
}

// MARK: - ReactionType Icon

extension ReactionType {
    var icon: UIImage? {
        switch self {
        case .awesome:
            return .Reaction.awesome
        case .great:
            return .Reaction.great
        case .amazing:
            return .Reaction.amazing
        case .fighting:
            return .Reaction.fighting
        }
    }
}

#if DEBUG
#Preview("ReactionButtonsView") {
    let view = ReactionButtonsView()
    view.configure(with: .preview)
    return view
}

#Preview("ReactionButtonsView - Scraped") {
    let view = ReactionButtonsView()
    view.configure(with: .previewScraped)
    return view
}

#Preview("ReactionButtonsView - All Reactions") {
    let view = ReactionButtonsView()
    view.configure(with: .previewWithAllReactions)
    return view
}
#endif
