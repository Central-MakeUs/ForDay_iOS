//
//  FeedItemCell.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class FeedItemCell: UICollectionViewCell {

    // MARK: - UI Components

    // Image mode views
    private let thumbnailImageView = UIImageView()

    // Gradient mode views
    private let gradientContainerView = UIView()
    private let quoteIconImageView = UIImageView()
    private let memoLabel = UILabel()

    // Overlay views
    private let dimView = UIView()
    private let radioButton = UIImageView()

    // MARK: - Properties

    // Store pending gradient for layoutSubviews application
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
        thumbnailImageView.kf.cancelDownloadTask()
        thumbnailImageView.image = nil
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

    func configure(feedItem: FeedItem, isSelectionMode: Bool, isSelected: Bool) {
        // Branch based on thumbnailImageUrl
        if !feedItem.thumbnailImageUrl.isEmpty {
            // Image mode: Show image
            showImageMode(imageUrl: feedItem.thumbnailImageUrl)
        } else {
            // Gradient mode: Show gradient + memo
            showGradientMode(
                memo: feedItem.memo,
                stickerType: feedItem.stickerType
            )
        }

        // Selection mode일 때 선택되지 않은 셀만 dim 처리
        // Selection mode가 아닐 때는 dim 없음 (그라디언트/이미지가 바로 보임)
        dimView.isHidden = !isSelectionMode || isSelected

        // Selection mode이고 선택된 경우 라디오 버튼 표시
        radioButton.isHidden = !isSelectionMode || !isSelected

        if isSelected {
            radioButton.image = UIImage(systemName: "checkmark.circle.fill")
            radioButton.tintColor = .action001
        }
    }

    private func showImageMode(imageUrl: String) {
        // Reset gradient mode
        isGradientMode = false
        pendingGradient = nil

        // Show image view, hide gradient views
        thumbnailImageView.isHidden = false
        gradientContainerView.isHidden = true

        // Load image
        guard let url = URL(string: imageUrl) else {
            thumbnailImageView.image = UIImage(systemName: "photo")
            thumbnailImageView.tintColor = .systemGray3
            return
        }

        let placeholder = UIImage(systemName: "photo")
        thumbnailImageView.kf.setImage(
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
        thumbnailImageView.isHidden = true
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

extension FeedItemCell {
    private func style() {
        contentView.backgroundColor = .systemGray6
        contentView.clipsToBounds = true

        thumbnailImageView.do {
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
            $0.font = .systemFont(ofSize: 10, weight: .regular)
            $0.textColor = .white
            $0.textAlignment = .left
            $0.numberOfLines = 2
            $0.lineBreakMode = .byTruncatingTail
        }

        dimView.do {
            $0.backgroundColor = .white.withAlphaComponent(0.6)
            $0.isHidden = false
        }

        radioButton.do {
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }
    }

    private func layout() {
        // Image view (for image mode)
        contentView.addSubview(thumbnailImageView)

        // Gradient container (for gradient mode)
        contentView.addSubview(gradientContainerView)
        gradientContainerView.addSubview(quoteIconImageView)
        gradientContainerView.addSubview(memoLabel)

        // Overlay views
        contentView.addSubview(dimView)
        contentView.addSubview(radioButton)

        // Image view layout
        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Gradient container layout
        gradientContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Quote icon layout
        quoteIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.width.height.equalTo(16)
        }

        // Memo label layout
        memoLabel.snp.makeConstraints {
            $0.top.equalTo(quoteIconImageView.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }

        // Dim view
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Radio button
        radioButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.width.height.equalTo(24)
        }
    }
}
