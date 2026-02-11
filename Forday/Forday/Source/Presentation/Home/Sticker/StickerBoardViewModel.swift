//
//  StickerBoardViewModel.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation
import Combine

final class StickerBoardViewModel {

    // MARK: - Published Properties

    @Published var viewState: ViewState = .loading
    @Published var stickerBoard: StickerBoard?
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let fetchStickerBoardUseCase: FetchStickerBoardUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Navigation Callbacks

    var onNavigateToActivityDetail: ((Int) -> Void)? // (activityRecordId)
    var onNavigateToActivityRecord: (() -> Void)? // Navigate to activity record screen

    // MARK: - Initialization

    init(fetchStickerBoardUseCase: FetchStickerBoardUseCase = FetchStickerBoardUseCase()) {
        self.fetchStickerBoardUseCase = fetchStickerBoardUseCase
    }

    // MARK: - Private Properties

    private var currentHobbyId: Int?

    // MARK: - Public Methods

    /// 초기 로드: 페이지 번호 없이 조회 (마지막 페이지 반환)
    /// - Parameter hobbyId: 취미 ID (nil이면 진행 중인 취미 없음으로 처리)
    func loadInitialStickerBoard(hobbyId: Int? = nil) async {
        // hobbyId가 nil이든 아니든 항상 갱신 (nil도 유효한 상태)
        currentHobbyId = hobbyId
        await loadStickerBoard(page: nil)
    }

    /// 특정 페이지 로드
    func loadPage(_ page: Int) async {
        await loadStickerBoard(page: page)
    }

    /// 이전 페이지로 이동
    func loadPreviousPage() async {
        guard let board = stickerBoard, board.hasPrevious else { return }
        await loadStickerBoard(page: board.currentPage - 1)
    }

    /// 다음 페이지로 이동
    func loadNextPage() async {
        guard let board = stickerBoard, board.hasNext else { return }
        await loadStickerBoard(page: board.currentPage + 1)
    }

    /// 스티커 탭 처리
    func didTapSticker(at index: Int) {
        guard let board = stickerBoard else { return }

        // 핑크 외곽선 스티커 (오늘 기록 안 함)
        if index == board.stickers.count && !board.activityRecordedToday {
            navigateToActivityRecord()
            return
        }

        // 이미 채워진 스티커 (삭제되지 않은 경우만)
        if index < board.stickers.count {
            let sticker = board.stickers[index]

            // 삭제된 스티커는 상세조회 불가
            guard sticker.stickerType != nil else { return }

            navigateToActivityDetail(activityRecordId: sticker.activityRecordId)
        }

        // 회색 빈 스티커 및 삭제된 스티커는 아무 동작 없음
    }

    // MARK: - Private Methods

    private func loadStickerBoard(page: Int?) async {
        // hobbyId가 nil이면 API 호출 없이 바로 noHobby 상태 반환
        guard currentHobbyId != nil else {
            await MainActor.run {
                self.stickerBoard = nil
                self.viewState = .noHobby
            }
            return
        }

        await MainActor.run {
            self.viewState = .loading
        }

        do {
            let result = try await fetchStickerBoardUseCase.execute(hobbyId: currentHobbyId, page: page)

            await MainActor.run {
                switch result {
                case .loaded(let board):
                    self.stickerBoard = board
                    self.viewState = .loaded

                case .noHobbyInProgress:
                    self.stickerBoard = nil
                    self.viewState = .noHobby

                case .emptyBoard(let board):
                    self.stickerBoard = board
                    self.viewState = .empty
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.viewState = .error
            }
        }
    }

    private func navigateToActivityRecord() {
        print("🎯 Navigate to Activity Record")
        onNavigateToActivityRecord?()
    }

    private func navigateToActivityDetail(activityRecordId: Int) {
        print("🎯 Navigate to Activity Detail: \(activityRecordId)")
        onNavigateToActivityDetail?(activityRecordId)
    }

    // MARK: - View State

    enum ViewState {
        case loading
        case loaded
        case noHobby
        case empty
        case error
    }
}
