//
//  BlockUserBottomSheetViewController.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import UIKit
import SnapKit
import Then

final class BlockUserBottomSheetViewController: UIViewController {

    // MARK: - Properties

    private var bottomSheetView: BlockUserBottomSheetView {
        return view as! BlockUserBottomSheetView
    }

    private let nickname: String
    private var shouldBlockUser: Bool = false
    private let onConfirm: (Bool) -> Void

    // MARK: - Initialization

    init(nickname: String, onConfirm: @escaping (Bool) -> Void) {
        self.nickname = nickname
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = BlockUserBottomSheetView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActions()
    }
}

// MARK: - Setup

extension BlockUserBottomSheetViewController {
    private func setupView() {
        bottomSheetView.configure(nickname: nickname)
        bottomSheetView.updateCheckboxState(isChecked: shouldBlockUser)
    }

    private func setupActions() {
        bottomSheetView.checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        bottomSheetView.confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        // Make checkbox container tappable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkboxTapped))
        bottomSheetView.checkboxButton.superview?.addGestureRecognizer(tapGesture)
        bottomSheetView.checkboxButton.superview?.isUserInteractionEnabled = true
    }
}

// MARK: - Actions

extension BlockUserBottomSheetViewController {
    @objc private func checkboxTapped() {
        shouldBlockUser.toggle()
        bottomSheetView.updateCheckboxState(isChecked: shouldBlockUser)
    }

    @objc private func confirmTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.onConfirm(self.shouldBlockUser)
        }
    }
}

#if DEBUG
#Preview {
    let vc = BlockUserBottomSheetViewController(nickname: "테스트닉네임") { shouldBlock in
        print("Should block: \(shouldBlock)")
    }
    return vc
}
#endif
