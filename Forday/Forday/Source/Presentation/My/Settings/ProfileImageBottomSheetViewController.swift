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

    // MARK: - Lifecycle

    override func loadView() {
        view = ProfileImageBottomSheetView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
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
    }
}

// MARK: - Actions

extension ProfileImageBottomSheetViewController {
    @objc private func selectFromAlbumTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onOptionSelected?(.selectFromAlbum)
        }
    }

    @objc private func setDefaultImageTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onOptionSelected?(.setDefaultImage)
        }
    }
}

#if DEBUG
#Preview {
    ProfileImageBottomSheetViewController()
}
#endif
