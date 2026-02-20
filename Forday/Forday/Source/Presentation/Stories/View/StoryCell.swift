//
//  StoryCell.swift
//  Forday
//
//  Created by Subeen on 2/19/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

protocol StoryCellDelegate: AnyObject {
    func storyCellDidTapGreatButton(_ cell: StoryCell, recordId: Int)
    func storyCellDidTapContent(_ cell: StoryCell, recordId: Int)
}

final class StoryCell: UICollectionViewCell {

    // MARK: - Properties

    static let identifier = "StoryCell"

    weak var delegate: StoryCellDelegate?
    private var recordId: Int?

    // Thumbnail container
    private let thumbnailContainerView = UIView()

    // Image mode views
    private let imageView = UIImageView()

    // Gradient mode views
    private let gradientContainerView = UIView()
    private let quoteIconImageView = UIImageView()
    private let memoLabel = UILabel()

    // Sticker image view
    private let stickerImageView = UIImageView()

    // Info views
    private let titleLabel = UILabel()
    private let userInfoStackView = UIStackView()
    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let greatButton = UIButton(type: .custom)

    // Store pending gradient for async application
    private var pendingGradient: AppGradient?
    private var isGradientMode: Bool = false

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

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        stickerImageView.image = nil
        memoLabel.text = nil
        titleLabel.text = nil
        nicknameLabel.text = nil
        profileImageView.image = nil
        pendingGradient = nil
        isGradientMode = false
        recordId = nil

        // Remove gradient layers
        gradientContainerView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        // Reset great button state
        greatButton.layer.borderColor = UIColor.stroke001.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Update gradient layer frame when bounds change
        if isGradientMode,
           let existingLayer = gradientContainerView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            existingLayer.frame = gradientContainerView.bounds
        }
    }

    // MARK: - Configuration

    func configure(with story: Story) {
        self.recordId = story.recordId

        // Title
        titleLabel.text = story.title

        // User info
        nicknameLabel.text = story.userInfo.nickname
        if let profileUrl = story.userInfo.profileImageUrl, !profileUrl.isEmpty {
            profileImageView.setImage(with: profileUrl)
        } else {
            profileImageView.image = .Icon.defaultProfile
        }

        // Great button state
        updateGreatButtonState(isPressed: story.pressedAwesome)

        // Sticker
        if let stickerType = story.stickerType {
            stickerImageView.image = stickerType.image
        }

        // Thumbnail or gradient
        if let thumbnailUrl = story.thumbnailUrl, !thumbnailUrl.isEmpty {
            showImageMode(imageUrl: thumbnailUrl)
        } else {
            showGradientMode(memo: story.memo, stickerType: story.stickerType)
        }
    }

    private func showImageMode(imageUrl: String) {
        imageView.isHidden = false
        gradientContainerView.isHidden = true
        isGradientMode = false

        imageView.setImage(with: imageUrl)
    }

    private func showGradientMode(memo: String?, stickerType: StickerType?) {
        isGradientMode = true
        imageView.isHidden = true
        gradientContainerView.isHidden = false

        let gradient = stickerType?.gradient ?? DesignGradient.gradient001
        pendingGradient = gradient

        gradientContainerView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        memoLabel.text = memo ?? ""

        DispatchQueue.main.async { [weak self] in
            self?.applyPendingGradientIfNeeded()
        }
    }

    private func applyPendingGradientIfNeeded() {
        guard isGradientMode,
              let gradient = pendingGradient,
              gradientContainerView.bounds.width > 0 else { return }

        gradientContainerView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        gradientContainerView.applyGradient(gradient)
    }

    private func updateGreatButtonState(isPressed: Bool) {
        if isPressed {
            greatButton.layer.borderColor = UIColor.action001.cgColor
        } else {
            greatButton.layer.borderColor = UIColor.stroke001.cgColor
        }
    }

    // MARK: - Actions

    private func setupActions() {
        greatButton.addTarget(self, action: #selector(greatButtonTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentTapped))
        thumbnailContainerView.addGestureRecognizer(tapGesture)
        thumbnailContainerView.isUserInteractionEnabled = true

        let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(contentTapped))
        titleLabel.addGestureRecognizer(titleTapGesture)
        titleLabel.isUserInteractionEnabled = true
    }

    @objc private func greatButtonTapped() {
        guard let recordId = recordId else { return }
        delegate?.storyCellDidTapGreatButton(self, recordId: recordId)
    }

    @objc private func contentTapped() {
        guard let recordId = recordId else { return }
        delegate?.storyCellDidTapContent(self, recordId: recordId)
    }
}

// MARK: - Setup

extension StoryCell {
    private func style() {
        contentView.backgroundColor = .clear

        thumbnailContainerView.do {
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.clipsToBounds = true
        }

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .bg003
        }

        gradientContainerView.do {
            $0.isHidden = true
        }

        quoteIconImageView.do {
            $0.image = .Icon.quotationMark
            $0.contentMode = .scaleAspectFit
        }

        memoLabel.do {
            $0.font = TypographyStyle.label12.font
            $0.textColor = .neutralWhite
            $0.textAlignment = .left
            $0.numberOfLines = 2
            $0.lineBreakMode = .byTruncatingTail
        }

        stickerImageView.do {
            $0.contentMode = .scaleAspectFit
        }

        titleLabel.do {
            $0.font = TypographyStyle.body16.font
            $0.textColor = .neutral900
            $0.numberOfLines = 2
            $0.lineBreakMode = .byTruncatingTail
        }

        userInfoStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }

        profileImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.image = .Icon.defaultProfile
        }

        nicknameLabel.do {
            $0.font = TypographyStyle.label12.font
            $0.textColor = .neutral500
        }

        greatButton.do {
            $0.setImage(.Reaction.great, for: .normal)
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
        }
    }

    private func layout() {
        contentView.addSubview(thumbnailContainerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(userInfoStackView)

        thumbnailContainerView.addSubview(imageView)
        thumbnailContainerView.addSubview(gradientContainerView)
        thumbnailContainerView.addSubview(stickerImageView)

        gradientContainerView.addSubview(quoteIconImageView)
        gradientContainerView.addSubview(memoLabel)

        userInfoStackView.addArrangedSubview(profileImageView)
        userInfoStackView.addArrangedSubview(nicknameLabel)

        contentView.addSubview(greatButton)

        // User info stack (bottom anchored, 24pt height)
        userInfoStackView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            $0.height.equalTo(24)
        }

        // Profile image
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }

        // Great button
        greatButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(userInfoStackView)
            $0.width.height.equalTo(24)
        }

        // Title label (above userInfo)
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(userInfoStackView.snp.top).offset(-4)
            $0.leading.trailing.equalToSuperview()
        }

        // Thumbnail container - fills remaining space above title
        thumbnailContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(titleLabel.snp.top).offset(-8)
        }

        // Image view
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Gradient container
        gradientContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Quote icon
        quoteIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(16)
        }

        // Memo label
        memoLabel.snp.makeConstraints {
            $0.top.equalTo(quoteIconImageView.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }

        // Sticker
        stickerImageView.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(10)
            $0.width.height.equalTo(40)
        }
    }
}
