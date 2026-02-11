//
//  StickerGridView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class StickerGridView: UIView {

    // MARK: - UI Components

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: createLayout()
    ).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.register(StickerBoardCell.self, forCellWithReuseIdentifier: StickerBoardCell.identifier)
        $0.dataSource = self
        $0.delegate = self
    }

    // MARK: - Properties

    private var board: StickerBoard?
    private var onStickerTap: ((Int) -> Void)?
    private var interactionEnabled: Bool = true

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .neutralWhite
        layer.cornerRadius = 16
        layer.borderColor = UIColor.stroke001.cgColor
        layer.borderWidth = 1

        addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
    }

    private func createLayout() -> UICollectionViewLayout {
        // 스티커 크기: Figma 기준 40x39px, 간격 최소화
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 7.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        // 그룹 높이를 조금 더 크게 설정하여 스티커 크기 증가
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(48) // 스티커 크기 증가
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 6 // 스티커 간 세로 간격 줄이기

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Configuration

    func configure(with board: StickerBoard, interactionEnabled: Bool = true, onStickerTap: @escaping (Int) -> Void) {
        self.board = board
        self.interactionEnabled = interactionEnabled
        self.onStickerTap = onStickerTap
        collectionView.reloadData()
    }

    // MARK: - Helper Methods

    /// 현재 페이지에 표시할 스티커 칸 개수 계산
    /// - 무제한: 항상 28칸
    /// - 66일: 진행 중(1~2페이지) = 28칸, 완료 시(3페이지) = 10칸
    private func cellCount() -> Int {
        guard let board = board else { return 0 }

        // 무제한: 항상 pageSize (28칸)
        if !board.durationSet {
            return board.pageSize
        }

        // 66일 설정
        // API 응답:
        // - totalPage: 현재까지 채운 스티커 기준 페이지
        // - totalStickerNum: 현재까지 채운 스티커 개수
        let goalDays = 66

        // 목표 기준 진짜 전체 페이지 수
        let realTotalPages = Int(ceil(Double(goalDays) / Double(board.pageSize)))
        // 66 / 28 = 2.357... → 3페이지

        // 진짜 마지막 페이지(66개 완료 시 3페이지)인지 확인
        if board.currentPage == realTotalPages {
            // 3페이지: 66 % 28 = 10칸
            let remaining = goalDays % board.pageSize
            return remaining > 0 ? remaining : board.pageSize
        } else {
            // 1~2페이지(진행 중): 항상 28칸 (빈칸 포함)
            // 예: 스티커 1개 찍으면 [1개 컬러 + 27개 회색]
            return board.pageSize
        }
    }

    private func stickerState(at index: Int) -> StickerItemView.StickerState {
        guard let board = board else { return .empty }

        // 실제 스티커가 있으면 표시
        if index < board.stickers.count {
            let sticker = board.stickers[index]

            // 삭제되었거나 sticker가 nil이면 빈 칸
            guard let stickerType = sticker.stickerType else {
                return .empty
            }

            return .filled(stickerType.rawValue)
        }

        // 오늘 활동 기록 안 함 && 채워진 스티커 바로 다음 칸 → 핑크 외곽선
        // 예: 스티커 3개 → index 0,1,2 = 컬러, index 3 = 핑크
        if index == board.stickers.count && !board.activityRecordedToday {
            return .todayHighlight
        }

        // 나머지는 회색 빈 칸
        return .empty
    }
}

// MARK: - UICollectionViewDataSource

extension StickerGridView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StickerBoardCell.identifier,
            for: indexPath
        ) as? StickerBoardCell else {
            return UICollectionViewCell()
        }

        let state = stickerState(at: indexPath.item)
        cell.configure(with: state)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension StickerGridView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard interactionEnabled else { return }
        onStickerTap?(indexPath.item)
    }
}

// MARK: - StickerBoardCell

private final class StickerBoardCell: UICollectionViewCell {

    static let identifier = "StickerBoardCell"

    private let stickerItemView = StickerItemView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(stickerItemView)

        stickerItemView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(with state: StickerItemView.StickerState) {
        stickerItemView.configure(with: state)
    }
}
