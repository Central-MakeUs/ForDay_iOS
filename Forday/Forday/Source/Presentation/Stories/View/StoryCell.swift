//
//  StoryCell.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class StoryCell: UICollectionViewCell {

    // MARK: - Properties

    static let identifier = "StoryCell"

    // Image mode views
    private let imageView = UIImageView()

    // Gradient mode views
    private let gradientContainerView = UIView()
    private let quoteIconImageView = UIImageView()
    private let memoLabel = UILabel()

    // Shared sticker image view
    private let stickerImageView = UIImageView()
    private let stickerBackgroundView = UIView()

    // Content views
    private let contentContainerView = UIView()
    private let titleLabel = UILabel()
    private let userInfoView = UserInfoView()
    private let reactionButton = UIButton()

    // Callbacks
    var onReactionTapped: (() -> Void)?
    var onUserInfoTapped: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        stickerImageView.image = nil
        memoLabel.text = nil
        titleLabel.text = nil

        // Remove gradient layers
        gradientContainerView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
    }

    // MARK: - Configuration

    func configure(with story: Story) {
        // Display sticker image
        if let stickerType = story.stickerType {
            stickerImageView.image = stickerType.image
        }

        // Branch based on thumbnailUrl
        if let thumbnailUrl = story.thumbnailUrl, !thumbnailUrl.isEmpty {
            // Image mode: Show image
            showImageMode(imageUrl: thumbnailUrl)
        } else {
            // Gradient mode: Show gradient + memo
            showGradientMode(
                memo: story.memo,
                stickerType: story.stickerType
            )
        }

        // Set title
        titleLabel.setTextWithTypography(story.title, style: .body14)

        // Set user info
        userInfoView.configure(
            profileImageUrl: story.userInfo.profileImageUrl,
            nickname: story.userInfo.nickname
        )

        // Set reaction state
        updateReactionButton(isPressed: story.pressedAwesome)
    }

    private func showImageMode(imageUrl: String) {
        // Show image view, hide gradient views
        imageView.isHidden = false
        gradientContainerView.isHidden = true

        // Load image
        guard let url = URL(string: imageUrl) else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .systemGray3
            return
        }

        let placeholder = UIImage(systemName: "photo")
        imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }

    private func showGradientMode(memo: String?, stickerType: StickerType?) {
        // Hide image view, show gradient views
        imageView.isHidden = true
        gradientContainerView.isHidden = false

        // Apply gradient background
        if let stickerType = stickerType {
            gradientContainerView.applyGradient(stickerType.gradient)
        } else {
            // Fallback to default gradient if sticker type unknown
            gradientContainerView.applyGradient(DesignGradient.gradient001)
        }

        // Set memo text (max 2 lines)
        memoLabel.text = memo ?? ""
    }

    private func updateReactionButton(isPressed: Bool) {
        let image: UIImage? = isPressed ? .Reaction.awesome : .Reaction.great
        reactionButton.setImage(image, for: .normal)
    }

    @objc private func handleReactionTapped() {
        onReactionTapped?()
    }

    @objc private func handleUserInfoTapped() {
        onUserInfoTapped?()
    }
}

// MARK: - Setup

extension StoryCell {
    private func style() {
        contentView.do {
            $0.backgroundColor = .systemBackground
            $0.clipsToBounds = true
        }

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .systemGray5
        }

        gradientContainerView.do {
            $0.isHidden = true
        }

        quoteIconImageView.do {
            $0.image = UIImage(systemName: "quote.opening")
            $0.tintColor = .white.withAlphaComponent(0.6)
            $0.contentMode = .scaleAspectFit
        }

        memoLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = .white
            $0.textAlignment = .left
            $0.numberOfLines = 2
            $0.lineBreakMode = .byTruncatingTail
        }

        stickerBackgroundView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            $0.clipsToBounds = true
        }

        stickerImageView.do {
            $0.contentMode = .scaleAspectFit
        }

        contentContainerView.do {
            $0.backgroundColor = .systemBackground
        }

        titleLabel.do {
            $0.textColor = .neutral900
            $0.numberOfLines = 2
            $0.lineBreakMode = .byTruncatingTail
        }

        userInfoView.do {
            $0.onTap = { [weak self] in
                self?.handleUserInfoTapped()
            }
        }

        reactionButton.do {
            $0.tintColor = .neutral600
            $0.addTarget(self, action: #selector(handleReactionTapped), for: .touchUpInside)
        }
    }

    private func layout() {
        // Image view (for image mode)
        contentView.addSubview(imageView)

        // Gradient container (for gradient mode)
        contentView.addSubview(gradientContainerView)
        gradientContainerView.addSubview(quoteIconImageView)
        gradientContainerView.addSubview(memoLabel)

        // Sticker (shared) - background view and image view
        contentView.addSubview(stickerBackgroundView)
        stickerBackgroundView.addSubview(stickerImageView)

        // Content container
        contentView.addSubview(contentContainerView)
        contentContainerView.addSubview(titleLabel)
        contentContainerView.addSubview(userInfoView)
        contentContainerView.addSubview(reactionButton)

        // Image view layout
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(imageView.snp.width).multipliedBy(128.0 / 119.0)  // Aspect ratio
        }

        // Gradient container layout
        gradientContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(gradientContainerView.snp.width).multipliedBy(128.0 / 119.0)
        }

        // Quote icon layout
        quoteIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(16)
        }

        // Memo label layout
        memoLabel.snp.makeConstraints {
            $0.top.equalTo(quoteIconImageView.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }

        // Sticker background layout (bottom-right of image area)
        stickerBackgroundView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.bottom.equalTo(imageView.snp.bottom).offset(-8)
            $0.width.height.equalTo(36)
        }

        // Sticker image layout (centered in background)
        stickerImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        // Content container layout
        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // Title label layout
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
        }

        // User info view layout
        userInfoView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(8)
        }

        // Reaction button layout
        reactionButton.snp.makeConstraints {
            $0.centerY.equalTo(userInfoView)
            $0.trailing.equalToSuperview().offset(-8)
            $0.width.height.equalTo(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-8)
        }

        // Make sticker background circular after layout
        DispatchQueue.main.async {
            self.stickerBackgroundView.layer.cornerRadius = 18
        }
    }
}
