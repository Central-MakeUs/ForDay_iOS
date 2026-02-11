//
//  ProfileImageBottomSheetViewController.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit

enum ProfileImageOption {
    case selectFromAlbum
    case setDefaultImage
}

final class ProfileImageBottomSheetViewController: UIViewController {

    // MARK: - Properties

    private var bottomSheetView: ProfileImageBottomSheetView {
        return view as! ProfileImageBottomSheetView
    }

    var onOptionSelected: ((ProfileImageOption) -> Void)?
    var onConfirm: (() -> Void)?

    private var selectedOption: ProfileImageOption?

    // MARK: - Lifecycle

    override func loadView() {
        view = ProfileImageBottomSheetView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        updateButtonStates()
    }
}

// MARK: - Setup

extension ProfileImageBottomSheetViewController {
    private func setupActions() {
        bottomSheetView.selectFromAlbumButton.addTarget(
            self,
            action: #selector(selectFromAlbumTapped),
            for: .touchUpInside
        )

        bottomSheetView.setDefaultImageButton.addTarget(
            self,
            action: #selector(setDefaultImageTapped),
            for: .touchUpInside
        )

        bottomSheetView.confirmButton.addTarget(
            self,
            action: #selector(confirmTapped),
            for: .touchUpInside
        )
    }

    private func updateButtonStates() {
        // Reset all button borders
        bottomSheetView.selectFromAlbumButton.layer.borderColor = UIColor.stroke001.cgColor
        bottomSheetView.setDefaultImageButton.layer.borderColor = UIColor.stroke001.cgColor

        // Highlight selected option
        switch selectedOption {
        case .selectFromAlbum:
            bottomSheetView.selectFromAlbumButton.layer.borderColor = UIColor.action001.cgColor
        case .setDefaultImage:
            bottomSheetView.setDefaultImageButton.layer.borderColor = UIColor.action001.cgColor
        case .none:
            break
        }
    }
}

// MARK: - Actions

extension ProfileImageBottomSheetViewController {
    @objc private func selectFromAlbumTapped() {
        selectedOption = .selectFromAlbum
        updateButtonStates()
        onOptionSelected?(.selectFromAlbum)
    }

    @objc private func setDefaultImageTapped() {
        selectedOption = .setDefaultImage
        updateButtonStates()
        onOptionSelected?(.setDefaultImage)
    }

    @objc private func confirmTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirm?()
        }
    }
}

#if DEBUG
#Preview {
    ProfileImageBottomSheetViewController()
}
#endif
