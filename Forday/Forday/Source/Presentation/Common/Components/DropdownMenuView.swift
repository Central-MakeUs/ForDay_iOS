//
//  DropdownMenuView.swift
//  Forday
//
//  Created by Subeen on 2/3/26.
//

import UIKit
import SnapKit
import Then

// MARK: - DropdownMenuItem Protocol

protocol DropdownMenuItem {
    var title: String { get }
    var textColor: UIColor { get }
    var fontWeight: TypographyStyle { get }
}

extension DropdownMenuItem {
    var textColor: UIColor { .neutral800 }
    var fontWeight: TypographyStyle { .body16 }
}

// MARK: - DropdownMenuView

final class DropdownMenuView: UIView {

    // MARK: - Properties

    private let containerView = UIView()
    private let stackView = UIStackView()
    private let items: [any DropdownMenuItem]
    private var itemViews: [(view: UIView, item: any DropdownMenuItem)] = []

    var onItemSelected: ((any DropdownMenuItem) -> Void)?

    // MARK: - Initialization

    init(items: [any DropdownMenuItem]) {
        self.items = items
        super.init(frame: .zero)
        style()
        layout()
        setupMenuItems()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions

    @objc private func handleMenuItemTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }

        if let matched = itemViews.first(where: { $0.view === tappedView }) {
            UIView.animate(
                withDuration: 0.1,
                animations: {
                    tappedView.alpha = 0.6
                },
                completion: { [weak self] _ in
                    UIView.animate(withDuration: 0.1) {
                        tappedView.alpha = 1
                    }
                    self?.onItemSelected?(matched.item)
                }
            )
        }
    }
}

// MARK: - Setup

extension DropdownMenuView {
    private func style() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        isHidden = true

        containerView.do {
            $0.backgroundColor = .bg001
            $0.layer.cornerRadius = 12
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.12
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 12
        }

        stackView.do {
            $0.axis = .vertical
            $0.spacing = 0
            $0.alignment = .fill
        }
    }

    private func layout() {
        addSubview(containerView)
        containerView.addSubview(stackView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }

    private func setupMenuItems() {
        for item in items {
            let menuItemView = createMenuItemView(for: item)
            itemViews.append((view: menuItemView, item: item))
            stackView.addArrangedSubview(menuItemView)
        }
    }

    private func createMenuItemView(for item: any DropdownMenuItem) -> UIView {
        let itemView = UIView()
        let label = UILabel()

        label.setTextWithTypography(item.title, style: item.fontWeight)
        label.textColor = item.textColor

        itemView.addSubview(label)

        itemView.snp.makeConstraints {
            $0.height.equalTo(40)
        }

        label.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMenuItemTap(_:)))
        itemView.addGestureRecognizer(tapGesture)

        return itemView
    }
}

// MARK: - Public Methods

extension DropdownMenuView {
    func showInParent(_ parentView: UIView, below sourceView: UIView, width: CGFloat = 200) {
        isHidden = false
        parentView.addSubview(self)

        let itemHeight: CGFloat = 40
        let verticalPadding: CGFloat = 20
        let totalHeight = CGFloat(items.count) * itemHeight + verticalPadding

        self.snp.makeConstraints {
            $0.top.equalTo(sourceView.snp.bottom).offset(8)
            $0.trailing.equalTo(sourceView)
            $0.width.equalTo(width)
            $0.height.equalTo(totalHeight)
        }

        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func showInParent(_ parentView: UIView, belowNavigationBar navigationBar: UINavigationBar, trailingOffset: CGFloat = 16, width: CGFloat = 200) {
        isHidden = false
        parentView.addSubview(self)

        let itemHeight: CGFloat = 40
        let verticalPadding: CGFloat = 20
        let totalHeight = CGFloat(items.count) * itemHeight + verticalPadding

        self.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-trailingOffset)
            $0.width.equalTo(width)
            $0.height.equalTo(totalHeight)
        }

        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
