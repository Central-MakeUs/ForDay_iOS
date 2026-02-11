//
//  ActivityPhotoCell.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ActivityPhotoCell: UICollectionViewCell {

    // MARK: - Properties

    static let identifier = "ActivityPhotoCell"

    // Image mode views
    private let imageView = UIImageView()

    // Gradient mode views
    private let gradientContainerView = UIView()
    private let quoteIconImageView = UIImageView()
    private let memoLabel = UILabel()

    // Shared sticker image view
    private let stickerImageView = UIImageView()

    // Store pending gradient for async application
    private var pendingGradient: AppGradient?
    private var isGradientMode: Bool = false

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
        pendingGradient = nil
        isGradientMode = false

        // Remove gradient layers
        gradientContainerView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
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

    func configure(with activity: FeedItem) {
        // Display sticker image
        if let stickerType = activity.stickerType {
            stickerImageView.image = stickerType.image
        }

        // Branch based on thumbnailImageUrl
        if !activity.thumbnailImageUrl.isEmpty {
            // Image mode: Show image
            showImageMode(imageUrl: activity.thumbnailImageUrl)
        } else {
            // Gradient mode: Show gradient + memo
            showGradientMode(
                memo: activity.memo,
                stickerType: activity.stickerType
            )
        }
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
        // Set gradient mode flag
        isGradientMode = true

        // Hide image view, show gradient views
        imageView.isHidden = true
        gradientContainerView.isHidden = false

        // Store gradient for layoutSubviews (handles timing issue)
        let gradient = stickerType?.gradient ?? DesignGradient.gradient001
        pendingGradient = gradient

        // Remove existing gradient layers before applying new one
        gradientContainerView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        // Set memo text (max 2 lines)
        memoLabel.text = memo ?? ""

        // Delay gradient application to next run loop when collection view has finished layout
        DispatchQueue.main.async { [weak self] in
            self?.applyPendingGradientIfNeeded()
        }
    }

    private func applyPendingGradientIfNeeded() {
        guard isGradientMode,
              let gradient = pendingGradient,
              gradientContainerView.bounds.width > 0 else { return }

        // Remove existing and apply fresh gradient
        gradientContainerView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        gradientContainerView.applyGradient(gradient)
    }
}

// MARK: - Setup

extension ActivityPhotoCell {
    private func style() {
        contentView.backgroundColor = .systemGray6
        contentView.clipsToBounds = true

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .systemGray5
        }

        gradientContainerView.do {
            $0.isHidden = true
        }

        quoteIconImageView.do {
            $0.image = .Icon.quotationMark
            $0.contentMode = .scaleAspectFit
        }

        memoLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = .white
            $0.textAlignment = .left
            $0.numberOfLines = 2
            $0.lineBreakMode = .byTruncatingTail
        }

        stickerImageView.do {
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        // Image view (for image mode)
        contentView.addSubview(imageView)

        // Gradient container (for gradient mode)
        contentView.addSubview(gradientContainerView)
        gradientContainerView.addSubview(quoteIconImageView)
        gradientContainerView.addSubview(memoLabel)

        // Sticker (shared)
        contentView.addSubview(stickerImageView)

        // Image view layout
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Gradient container layout
        gradientContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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

        // Sticker image layout (bottom-right, proportional to cell width)
        // Figma: 40x40 sticker on 119.33 width cell = 40/119.33 ≈ 0.335 ratio
        stickerImageView.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(10)
            $0.width.height.equalTo(contentView.snp.width).multipliedBy(40.0 / 119.33)
        }
    }
}
