//
//  HobbyFilterView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class HobbyFilterView: UIView {

    // MARK: - Properties

    private let collectionView: UICollectionView
    private var hobbies: [MyPageHobby] = []
    private var selectedHobbyIds: Set<Int> = [] // Empty = all hobbies

    var onHobbiesSelected: ((Set<Int>) -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 12

        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

        super.init(frame: frame)

        style()
        layout()
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with hobbies: [MyPageHobby]) {
        self.hobbies = hobbies
        collectionView.reloadData()
    }

    func selectHobbies(_ hobbyIds: Set<Int>) {
        let previousSelectedIds = selectedHobbyIds
        selectedHobbyIds = hobbyIds

        // Update only the cells that changed selection state
        for (index, hobby) in hobbies.enumerated() {
            let wasSelected = previousSelectedIds.contains(hobby.hobbyId)
            let isNowSelected = hobbyIds.contains(hobby.hobbyId)

            // Only update if selection state changed
            if wasSelected != isNowSelected {
                let indexPath = IndexPath(item: index, section: 0)
                if let cell = collectionView.cellForItem(at: indexPath) as? HobbyFilterCell {
                    cell.updateSelectionState(isSelected: isNowSelected)
                }
            }
        }
    }
}

// MARK: - Setup

extension HobbyFilterView {
    private func style() {
        backgroundColor = .systemBackground

        collectionView.do {
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
        }
    }

    private func layout() {
        addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20))
        }
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            HobbyFilterCell.self,
            forCellWithReuseIdentifier: HobbyFilterCell.identifier
        )
    }
}

// MARK: - UICollectionViewDataSource

extension HobbyFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hobbies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HobbyFilterCell.identifier,
            for: indexPath
        ) as? HobbyFilterCell else {
            return UICollectionViewCell()
        }

        let hobby = hobbies[indexPath.item]
        let isSelected = selectedHobbyIds.contains(hobby.hobbyId)
        cell.configure(with: hobby, isSelected: isSelected)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension HobbyFilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let hobby = hobbies[indexPath.item]

        // Calculate new selection state
        let isCurrentlySelected = selectedHobbyIds.contains(hobby.hobbyId)
        let willBeSelected = !isCurrentlySelected

        // Update local state immediately
        if willBeSelected {
            selectedHobbyIds.insert(hobby.hobbyId)
        } else {
            selectedHobbyIds.remove(hobby.hobbyId)
        }

        // Update the tapped cell immediately for instant feedback
        if let cell = collectionView.cellForItem(at: indexPath) as? HobbyFilterCell {
            cell.updateSelectionState(isSelected: willBeSelected)
        }

        // Notify selection change (ViewModel will update)
        onHobbiesSelected?(selectedHobbyIds)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HobbyFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Icon container (48pt) + spacing (4pt) + label height (~14pt)
        return CGSize(width: 48, height: 66)
    }
}

#Preview {
    HobbyFilterView()
}
