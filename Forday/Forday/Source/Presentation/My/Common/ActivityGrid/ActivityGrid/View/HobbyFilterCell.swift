//
//  HobbyFilterCell.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class HobbyFilterCell: UICollectionViewCell {

    // MARK: - Properties

    static let identifier = "HobbyFilterCell"

    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let selectionBorderView = UIView()

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
        iconImageView.kf.cancelDownloadTask()
        iconImageView.image = nil
    }

    // MARK: - Configuration

    func configure(with hobby: MyPageHobby, isSelected: Bool) {
        // Load thumbnail if available, otherwise show hobby-specific icon
        if let thumbnailImageUrl = hobby.thumbnailImageUrl,
           !thumbnailImageUrl.isEmpty,
           let url = URL(string: thumbnailImageUrl) {
            // Has thumbnail - load from URL (fill the circle)
            iconImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "camera.fill"),
                options: [
                    .transition(.fade(0.2)),
                    .forceRefresh  // Always fetch fresh image when URL changes
                ]
            )
            iconImageView.contentMode = .scaleAspectFill
            iconImageView.snp.remakeConstraints {
                $0.edges.equalToSuperview()
            }
        } else {
            // No thumbnail - show hobby-specific icon (small centered)
            if let imageAsset = HobbyImageAsset(hobbyName: hobby.hobbyName) {
                iconImageView.image = imageAsset.icon
                iconImageView.contentMode = .scaleAspectFit
            } else {
                // Fallback if hobby name doesn't match
                iconImageView.image = UIImage(systemName: "camera.fill")
                iconImageView.contentMode = .scaleAspectFit
            }
            iconImageView.snp.remakeConstraints {
                $0.center.equalToSuperview()
                $0.width.height.equalTo(20)
            }
        }

        // Force layout update after remakeConstraints
        iconContainerView.setNeedsLayout()
        iconContainerView.layoutIfNeeded()

        // Truncate hobby name if longer than 4 characters
        nameLabel.setTextWithTypography(hobby.hobbyName.truncated(maxLength: 4), style: .body12)

        // Apply dim for archived hobbies
        let alpha: CGFloat = hobby.status == .archived ? 0.4 : 1.0
        iconImageView.alpha = alpha
        nameLabel.alpha = alpha

        // Update selection border color based on state
        updateSelectionState(isSelected: isSelected)
    }

    /// Updates only the selection state (border color) without reconfiguring the entire cell
    func updateSelectionState(isSelected: Bool) {
        selectionBorderView.layer.borderColor = isSelected
            ? UIColor.action001.cgColor
            : UIColor.stroke001.cgColor
    }
}

// MARK: - Setup

extension HobbyFilterCell {
    private func style() {
        contentView.backgroundColor = .clear

        iconContainerView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 24
            $0.clipsToBounds = true
        }

        iconImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }

        nameLabel.do {
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        selectionBorderView.do {
            $0.layer.cornerRadius = 24
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.backgroundColor = .clear
        }
    }

    private func layout() {
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(selectionBorderView)
        contentView.addSubview(nameLabel)

        iconContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(48)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        selectionBorderView.snp.makeConstraints {
            $0.edges.equalTo(iconContainerView)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(iconContainerView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
}
