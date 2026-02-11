//
//  ProfileSegmentedControlView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class ProfileSegmentedControlView: UIView {

    // MARK: - Properties

    private let activitiesButton = UIButton()
    private let hobbyCardsButton = UIButton()
    private let scrapsButton = UIButton()
    private let underlineView = UIView()

    var onSegmentChanged: ((MyPageTab) -> Void)?
    private var selectedSegment: MyPageTab = .activities

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func updateCounts(inProgressCount: Int, hobbyCardsCount: Int, scrapsCount: Int = 0) {
        activitiesButton.setTitle("진행중 \(inProgressCount)", for: .normal)
        hobbyCardsButton.setTitle("취미카드 \(hobbyCardsCount)", for: .normal)
        scrapsButton.setTitle("스크랩", for: .normal)
    }

    func selectSegment(_ segment: MyPageTab, animated: Bool = false) {
        selectedSegment = segment

        updateSegmentAppearance(animated: animated)
    }

    // MARK: - Private Methods

    private func updateSegmentAppearance(animated: Bool) {
        let activitiesSelected = selectedSegment == .activities
        let hobbyCardsSelected = selectedSegment == .hobbyCards
        let scrapsSelected = selectedSegment == .scraps

        // Update button states
        activitiesButton.isSelected = activitiesSelected
        hobbyCardsButton.isSelected = hobbyCardsSelected
        scrapsButton.isSelected = scrapsSelected

        // Update colors
        activitiesButton.setTitleColor(
            activitiesSelected ? .label : .secondaryLabel,
            for: .normal
        )
        hobbyCardsButton.setTitleColor(
            hobbyCardsSelected ? .label : .secondaryLabel,
            for: .normal
        )
        scrapsButton.setTitleColor(
            scrapsSelected ? .label : .secondaryLabel,
            for: .normal
        )

        // Update underline position
        let targetButton = activitiesSelected ? activitiesButton : (hobbyCardsSelected ? hobbyCardsButton : scrapsButton)

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                self.underlineView.snp.remakeConstraints {
                    $0.bottom.equalToSuperview()
                    $0.height.equalTo(2)
                    $0.leading.equalTo(targetButton.snp.leading)
                    $0.trailing.equalTo(targetButton.snp.trailing)
                }
                self.layoutIfNeeded()
            }
        } else {
            underlineView.snp.remakeConstraints {
                $0.bottom.equalToSuperview()
                $0.height.equalTo(2)
                $0.leading.equalTo(targetButton.snp.leading)
                $0.trailing.equalTo(targetButton.snp.trailing)
            }
        }
    }
}

// MARK: - Setup

extension ProfileSegmentedControlView {
    private func style() {
        backgroundColor = .systemBackground

        activitiesButton.do {
            $0.setTitle("진행중 0", for: .normal)
            $0.setTitleColor(.label, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.isSelected = true
        }

        hobbyCardsButton.do {
            $0.setTitle("취미카드 0", for: .normal)
            $0.setTitleColor(.secondaryLabel, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        }

        scrapsButton.do {
            $0.setTitle("스크랩", for: .normal)
            $0.setTitleColor(.secondaryLabel, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        }

        underlineView.do {
            $0.backgroundColor = .label
        }
    }

    private func layout() {
        addSubview(activitiesButton)
        addSubview(hobbyCardsButton)
        addSubview(scrapsButton)
        addSubview(underlineView)

        activitiesButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(hobbyCardsButton)
        }

        hobbyCardsButton.snp.makeConstraints {
            $0.leading.equalTo(activitiesButton.snp.trailing).offset(20)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(scrapsButton)
        }

        scrapsButton.snp.makeConstraints {
            $0.leading.equalTo(hobbyCardsButton.snp.trailing).offset(20)
            $0.top.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        underlineView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
            $0.leading.equalTo(activitiesButton.snp.leading)
            $0.trailing.equalTo(activitiesButton.snp.trailing)
        }
    }

    private func setupActions() {
        activitiesButton.addTarget(
            self,
            action: #selector(activitiesButtonTapped),
            for: .touchUpInside
        )

        hobbyCardsButton.addTarget(
            self,
            action: #selector(hobbyCardsButtonTapped),
            for: .touchUpInside
        )

        scrapsButton.addTarget(
            self,
            action: #selector(scrapsButtonTapped),
            for: .touchUpInside
        )
    }
}

// MARK: - Actions

extension ProfileSegmentedControlView {
    @objc private func activitiesButtonTapped() {
        guard selectedSegment != .activities else { return }
        selectSegment(.activities, animated: true)
        onSegmentChanged?(.activities)
    }

    @objc private func hobbyCardsButtonTapped() {
        guard selectedSegment != .hobbyCards else { return }
        selectSegment(.hobbyCards, animated: true)
        onSegmentChanged?(.hobbyCards)
    }

    @objc private func scrapsButtonTapped() {
        guard selectedSegment != .scraps else { return }
        selectSegment(.scraps, animated: true)
        onSegmentChanged?(.scraps)
    }
}
