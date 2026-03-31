//
//  ActivityDetailViewModel.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation
import Combine

final class ActivityDetailViewModel {

    // MARK: - Published Properties

    @Published var activityDetail: ActivityDetail?
    @Published var isLoading: Bool = false
    @Published var error: AppError?
    @Published var reactionUsers: [ReactionUser] = []
    @Published var selectedReactionType: ReactionType?

    // MARK: - Private Properties

    let activityRecordId: Int  // PageViewController에서 접근 필요
    private let context: ActivityDetailContext?  // 페이징을 위한 컨텍스트
    private let fetchActivityDetailUseCase: FetchActivityDetailUseCase
    private let addReactionUseCase: AddReactionUseCase
    private let deleteReactionUseCase: DeleteReactionUseCase
    private let fetchReactionUsersUseCase: FetchReactionUsersUseCase
    private let deleteActivityRecordUseCase: DeleteActivityRecordUseCase
    private let updateHobbyCoverUseCase: UpdateHobbyCoverUseCase
    private let addScrapUseCase: AddScrapUseCase
    private let deleteScrapUseCase: DeleteScrapUseCase

    private var lastUserId: String? = nil
    private var hasMoreUsers: Bool = true

    // MARK: - Public Properties

    var hobbyId: Int {
        return activityDetail?.hobbyId ?? 0
    }

    var prevRecordId: Int? {
        return activityDetail?.prevRecordId
    }

    var nextRecordId: Int? {
        return activityDetail?.nextRecordId
    }

    // MARK: - Initialization

    init(
        activityRecordId: Int,
        context: ActivityDetailContext? = nil,
        fetchActivityDetailUseCase: FetchActivityDetailUseCase = FetchActivityDetailUseCase(),
        addReactionUseCase: AddReactionUseCase = AddReactionUseCase(),
        deleteReactionUseCase: DeleteReactionUseCase = DeleteReactionUseCase(),
        fetchReactionUsersUseCase: FetchReactionUsersUseCase = FetchReactionUsersUseCase(),
        deleteActivityRecordUseCase: DeleteActivityRecordUseCase = DeleteActivityRecordUseCase(),
        updateHobbyCoverUseCase: UpdateHobbyCoverUseCase = UpdateHobbyCoverUseCase(),
        addScrapUseCase: AddScrapUseCase = AddScrapUseCase(),
        deleteScrapUseCase: DeleteScrapUseCase = DeleteScrapUseCase()
    ) {
        self.activityRecordId = activityRecordId
        self.context = context
        self.fetchActivityDetailUseCase = fetchActivityDetailUseCase
        self.addReactionUseCase = addReactionUseCase
        self.deleteReactionUseCase = deleteReactionUseCase
        self.fetchReactionUsersUseCase = fetchReactionUsersUseCase
        self.deleteActivityRecordUseCase = deleteActivityRecordUseCase
        self.updateHobbyCoverUseCase = updateHobbyCoverUseCase
        self.addScrapUseCase = addScrapUseCase
        self.deleteScrapUseCase = deleteScrapUseCase
    }

    // MARK: - Public Methods

    func fetchDetail() async {
        await MainActor.run {
            isLoading = true
        }

        do {
            let detail = try await fetchActivityDetailUseCase.execute(activityRecordId: activityRecordId, context: context)

            await MainActor.run {
                self.activityDetail = detail
                self.isLoading = false
            }

        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
                self.isLoading = false
            }
        }
    }

    // MARK: - Reaction Methods

    /// 반응을 추가하거나 삭제합니다.
    /// 이미 눌러진 반응이면 삭제, 아니면 추가합니다.
    func toggleReaction(_ reactionType: ReactionType) async {
        guard let detail = activityDetail else { return }

        // 현재 반응 상태 확인
        let isCurrentlyPressed = isReactionPressed(reactionType, in: detail.userReaction)

        // 현재 열려있는 유저 목록의 반응 타입 저장
        let wasShowingUsers = selectedReactionType

        do {
            if isCurrentlyPressed {
                // 반응 삭제
                _ = try await deleteReactionUseCase.execute(
                    recordId: activityRecordId,
                    reactionType: reactionType
                )
            } else {
                // 반응 추가
                _ = try await addReactionUseCase.execute(
                    recordId: activityRecordId,
                    reactionType: reactionType
                )
            }

            // 성공 시 상세 정보 다시 불러오기
            await fetchDetail()

            // 유저 목록이 열려있었다면 다시 불러오기 (forceRefresh로 무조건 갱신)
            if let showingType = wasShowingUsers {
                await fetchReactionUsers(for: showingType, forceRefresh: true)
            }

        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
            }
        }
    }

    private func isReactionPressed(_ reactionType: ReactionType, in reaction: ReactionStatus) -> Bool {
        switch reactionType {
        case .awesome: return reaction.awesome
        case .great: return reaction.great
        case .amazing: return reaction.amazing
        case .fighting: return reaction.fighting
        }
    }

    // MARK: - Reaction Users Methods

    /// 특정 반응을 남긴 사용자 목록을 조회합니다.
    /// - Parameters:
    ///   - reactionType: 조회할 반응 타입
    ///   - forceRefresh: true이면 같은 타입이어도 무조건 새로 조회 (기본값: false)
    func fetchReactionUsers(for reactionType: ReactionType, forceRefresh: Bool = false) async {
        // 같은 반응을 다시 탭하면 닫기 (forceRefresh가 아닐 때만)
        if !forceRefresh && selectedReactionType == reactionType {
            await closeReactionUsers()
            return
        }

        do {
            let result = try await fetchReactionUsersUseCase.execute(
                recordId: activityRecordId,
                reactionType: reactionType,
                lastUserId: nil,
                size: 10
            )

            await MainActor.run {
                self.reactionUsers = result.reactionUsers
                self.selectedReactionType = reactionType
                self.lastUserId = result.lastUserId
                self.hasMoreUsers = result.hasNext
            }

        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
            }
        }
    }

    /// 반응 사용자 목록을 닫습니다.
    func closeReactionUsers() async {
        await MainActor.run {
            self.reactionUsers = []
            self.selectedReactionType = nil
            self.lastUserId = nil
            self.hasMoreUsers = true
        }
    }

    // MARK: - Activity Record Actions

    /// 활동 기록을 삭제합니다.
    func deleteRecord() async throws {
        _ = try await deleteActivityRecordUseCase.execute(recordId: activityRecordId)
    }

    /// 이 활동 기록의 이미지를 취미 대표사진으로 설정합니다.
    func setCoverImage() async throws {
        _ = try await updateHobbyCoverUseCase.executeWithRecord(recordId: activityRecordId)
    }

    // MARK: - Scrap Methods

    /// 스크랩을 추가하거나 삭제합니다.
    /// 이미 스크랩된 상태면 삭제, 아니면 추가합니다.
    func toggleScrap() async {
        guard let detail = activityDetail else { return }

        // 현재 열려있는 유저 목록의 반응 타입 저장
        let wasShowingUsers = selectedReactionType

        do {
            if detail.scraped {
                // 스크랩 삭제
                _ = try await deleteScrapUseCase.execute(recordId: activityRecordId)
            } else {
                // 스크랩 추가
                _ = try await addScrapUseCase.execute(recordId: activityRecordId)
            }

            // 성공 시 상세 정보 다시 불러오기
            await fetchDetail()

            // 스크랩 목록 갱신을 위해 이벤트 발송
            await MainActor.run {
                AppEventBus.shared.scrapDidUpdate.send()
            }

            // 유저 목록이 열려있었다면 다시 불러오기 (forceRefresh로 무조건 갱신)
            if let showingType = wasShowingUsers {
                await fetchReactionUsers(for: showingType, forceRefresh: true)
            }

        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
            }
        }
    }
}
