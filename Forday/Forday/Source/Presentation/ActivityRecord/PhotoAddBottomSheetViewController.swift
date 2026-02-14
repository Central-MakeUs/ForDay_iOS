//
//  PhotoAddBottomSheetViewController.swift
//  Forday
//
//  Created by Subeen on 2/14/26.
//

import UIKit
import SnapKit
import Then

enum PhotoAddOption {
    case album
    case camera
}

final class PhotoAddBottomSheetViewController: UIViewController {

    // MARK: - Properties

    private let dimView = UIView()
    private let bottomSheetView = PhotoAddBottomSheetView()

    var onOptionSelected: ((PhotoAddOption) -> Void)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupActions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
}

// MARK: - Setup

extension PhotoAddBottomSheetViewController {
    private func style() {
        view.backgroundColor = .clear

        dimView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            $0.alpha = 0
        }

        bottomSheetView.do {
            $0.transform = CGAffineTransform(translationX: 0, y: 300)
        }
    }

    private func layout() {
        view.addSubview(dimView)
        view.addSubview(bottomSheetView)

        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupActions() {
        // Dim 영역 탭하면 dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimViewTapped))
        dimView.addGestureRecognizer(tapGesture)

        // 버튼 액션
        bottomSheetView.albumButton.addTarget(
            self,
            action: #selector(albumButtonTapped),
            for: .touchUpInside
        )

        bottomSheetView.cameraButton.addTarget(
            self,
            action: #selector(cameraButtonTapped),
            for: .touchUpInside
        )
    }
}

// MARK: - Actions

extension PhotoAddBottomSheetViewController {
    @objc private func dimViewTapped() {
        animateOut()
    }

    @objc private func albumButtonTapped() {
        animateOut { [weak self] in
            self?.onOptionSelected?(.album)
        }
    }

    @objc private func cameraButtonTapped() {
        animateOut { [weak self] in
            self?.onOptionSelected?(.camera)
        }
    }
}

// MARK: - Animation

extension PhotoAddBottomSheetViewController {
    private func animateIn() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.dimView.alpha = 1
            self.bottomSheetView.transform = .identity
        }
    }

    private func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.dimView.alpha = 0
            self.bottomSheetView.transform = CGAffineTransform(translationX: 0, y: 300)
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
}

#if DEBUG
#Preview {
    PhotoAddBottomSheetViewController()
}
#endif
