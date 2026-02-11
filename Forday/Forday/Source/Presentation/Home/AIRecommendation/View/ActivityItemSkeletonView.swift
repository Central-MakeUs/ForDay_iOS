//
//  ActivityItemSkeletonView.swift
//  Forday
//
//  Created by Subeen on 2/11/26.
//

import UIKit
import SnapKit
import Then

final class ActivityItemSkeletonView: UIView {

    // MARK: - UI Components

    private let containerView = UIView()
    private let titleSkeleton = SkeletonView()
    private let checkboxSkeleton = SkeletonView()
    private let descriptionSkeleton1 = SkeletonView()
    private let descriptionSkeleton2 = SkeletonView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension ActivityItemSkeletonView {
    private func style() {
        containerView.do {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 12
        }

        titleSkeleton.do {
            $0.layer.cornerRadius = 4
        }

        checkboxSkeleton.do {
            $0.layer.cornerRadius = 4
        }

        descriptionSkeleton1.do {
            $0.layer.cornerRadius = 4
        }

        descriptionSkeleton2.do {
            $0.layer.cornerRadius = 4
        }
    }

    private func layout() {
        addSubview(containerView)
        containerView.addSubview(titleSkeleton)
        containerView.addSubview(checkboxSkeleton)
        containerView.addSubview(descriptionSkeleton1)
        containerView.addSubview(descriptionSkeleton2)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleSkeleton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(120)
            $0.height.equalTo(20)
        }

        checkboxSkeleton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(16)
            $0.width.height.equalTo(20)
        }

        descriptionSkeleton1.snp.makeConstraints {
            $0.top.equalTo(titleSkeleton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(16)
        }

        descriptionSkeleton2.snp.makeConstraints {
            $0.top.equalTo(descriptionSkeleton1.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalToSuperview().multipliedBy(0.6)
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}

// MARK: - Public Methods

extension ActivityItemSkeletonView {
    func startAnimating() {
        titleSkeleton.startAnimating()
        checkboxSkeleton.startAnimating()
        descriptionSkeleton1.startAnimating()
        descriptionSkeleton2.startAnimating()
    }

    func stopAnimating() {
        titleSkeleton.stopAnimating()
        checkboxSkeleton.stopAnimating()
        descriptionSkeleton1.stopAnimating()
        descriptionSkeleton2.stopAnimating()
    }
}

#if DEBUG
#Preview("ActivityItemSkeletonView") {
    let view = ActivityItemSkeletonView()
    view.backgroundColor = .bg001
    view.startAnimating()
    return view
}
#endif
