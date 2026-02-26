//
//  HobbyCardStackViewController.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class HobbyCardStackViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ProfileViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    private let titleLabel = UILabel()
    private let cardStackView = HobbyCardStackView()
    private let emptyStateView = EmptyStateView()

    // Callback for content height change (for parent scroll adjustment)
    var onContentHeightChanged: ((CGFloat) -> Void)?

    // MARK: - Initialization

    init(viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        bind()
    }
}

// MARK: - Setup

extension HobbyCardStackViewController {
    private func style() {
        view.backgroundColor = .systemBackground

        titleLabel.do {
            $0.setTextWithTypography("66일이 지속된 취미카드예요!", style: .header18)
            $0.textColor = .neutral900
            $0.textAlignment = .left
        }
    }

    private func layout() {
        view.addSubview(titleLabel)
        view.addSubview(cardStackView)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        cardStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-40)
            $0.height.equalTo(cardStackView.snp.width).multipliedBy(1.5) // 2:3 aspect ratio
        }
    }

    private func bind() {
        viewModel.hobbyCardsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cards in
                self?.updateContent(cards: cards)
            }
            .store(in: &cancellables)
    }

    private func updateContent(cards: [CompletedHobbyCard]) {
        if cards.isEmpty {
            // Show empty state
            cardStackView.isHidden = true
            titleLabel.isHidden = true

            if emptyStateView.superview == nil {
                view.addSubview(emptyStateView)
                emptyStateView.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(100)
                    $0.leading.trailing.equalToSuperview()
                    $0.height.equalTo(200)
                }
            }

            emptyStateView.configureForHobbyCards()

            // Notify parent about height change for empty state
            // top offset(100) + emptyStateView(200) + bottomPadding(100)
            onContentHeightChanged?(400)
        } else {
            // Show cards
            cardStackView.isHidden = false
            titleLabel.setTextWithTypography("66일이 지속된 취미카드예요!", style: .header18)
            titleLabel.isHidden = false
            emptyStateView.removeFromSuperview()

            cardStackView.configure(with: cards)

            // Notify parent about height change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.notifyContentHeight()
            }
        }
    }

    private func notifyContentHeight() {
        view.layoutIfNeeded()

        // Calculate total height: title(~25) + spacing(20) + cardStackView height + bottom padding(40)
        let titleHeight: CGFloat = 25
        let topPadding: CGFloat = 20
        let spacing: CGFloat = 20
        let cardHeight = cardStackView.frame.height
        let bottomPadding: CGFloat = 40

        let totalHeight = topPadding + titleHeight + spacing + cardHeight + bottomPadding
        onContentHeightChanged?(totalHeight)
    }

    /// Force recalculate and notify content height (called when view is re-added to parent)
    func refreshContentHeight() {
        view.layoutIfNeeded()
        notifyContentHeight()
    }
}
