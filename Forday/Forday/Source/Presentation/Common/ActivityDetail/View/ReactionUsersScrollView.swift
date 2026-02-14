//
//  ReactionUsersScrollView.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import UIKit
import SnapKit
import Then

final class ReactionUsersScrollView: UIView {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    // MARK: - Properties

    private var userCells: [ReactionUserCell] = []

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with users: [ReactionUser]) {
        // Clear existing cells
        userCells.forEach { $0.removeFromSuperview() }
        userCells.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add new cells
        users.forEach { user in
            let cell = ReactionUserCell()
            cell.configure(with: user)

            cell.snp.makeConstraints {
                $0.width.equalTo(60)  // Enough width for 28pt image + padding
            }

            stackView.addArrangedSubview(cell)
            userCells.append(cell)
        }
    }

    func clear() {
        userCells.forEach { $0.removeFromSuperview() }
        userCells.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: - Setup

extension ReactionUsersScrollView {
    private func style() {
        clipsToBounds = false

        scrollView.do {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceHorizontal = true
            $0.clipsToBounds = false
        }

        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 10
            $0.alignment = .fill
            $0.distribution = .equalSpacing
            $0.clipsToBounds = false
        }
    }

    private func layout() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            $0.height.equalToSuperview()
        }
    }
}

#if DEBUG
#Preview("ReactionUsersScrollView - Empty") {
    let view = ReactionUsersScrollView()
    view.frame = CGRect(x: 0, y: 0, width: 375, height: 60)
    return view
}

#Preview("ReactionUsersScrollView - With Users") {
    let view = ReactionUsersScrollView()
    view.configure(with: ReactionUser.previewList)
    view.frame = CGRect(x: 0, y: 0, width: 375, height: 60)
    return view
}
#endif
