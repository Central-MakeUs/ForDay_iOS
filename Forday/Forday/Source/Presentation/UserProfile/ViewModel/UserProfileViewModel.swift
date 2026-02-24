//
//  UserProfileViewModel.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import Foundation
import Combine

@MainActor
final class UserProfileViewModel: ProfileViewModelProtocol {

    // MARK: - Published Properties

    @Published var userProfile: UserInfo?
    @Published var currentTab: MyPageTab = .activities
    @Published var myHobbies: [MyPageHobby] = []
    @Published var inProgressHobbyCount: Int = 0
    @Published var hobbyCardCount: Int = 0
    @Published var activities: [FeedItem] = []
    @Published var hobbyCards: [CompletedHobbyCard] = []
    @Published var scraps: [FeedItem] = []
    @Published var totalActivityCount: Int = 0
    @Published var totalScrapCount: Int = 0
    @Published var selectedHobbyIds: Set<Int> = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var error: AppError?

    // MARK: - Private Properties

    private let userId: String
    private var lastRecordId: Int? = nil
    private var hasMoreActivities: Bool = true
    private var lastHobbyCardId: Int? = nil
    private var hasMoreHobbyCards: Bool = true
    private var lastScrapRecordId: Int? = nil
    private var hasMoreScraps: Bool = true

    // Use Cases
    private let fetchUserProfileUseCase: FetchUserProfileUseCase
    private let fetchMyActivitiesUseCase: FetchMyActivitiesUseCase
    private let fetchMyHobbiesUseCase: FetchMyHobbiesUseCase
    private let fetchHobbyCardsUseCase: FetchHobbyCardsUseCase
    private let fetchScrapsUseCase: FetchScrapsUseCase

    // MARK: - Initialization

    init(
        userId: String,
        fetchUserProfileUseCase: FetchUserProfileUseCase = FetchUserProfileUseCase(),
        fetchMyActivitiesUseCase: FetchMyActivitiesUseCase = FetchMyActivitiesUseCase(),
        fetchMyHobbiesUseCase: FetchMyHobbiesUseCase = FetchMyHobbiesUseCase(),
        fetchHobbyCardsUseCase: FetchHobbyCardsUseCase = FetchHobbyCardsUseCase(),
        fetchScrapsUseCase: FetchScrapsUseCase = FetchScrapsUseCase()
    ) {
        self.userId = userId
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.fetchMyActivitiesUseCase = fetchMyActivitiesUseCase
        self.fetchMyHobbiesUseCase = fetchMyHobbiesUseCase
        self.fetchHobbyCardsUseCase = fetchHobbyCardsUseCase
        self.fetchScrapsUseCase = fetchScrapsUseCase
    }

    // MARK: - Public Methods

    func fetchInitialData() async {
        isLoading = true

        // 병렬로 모든 데이터 fetch (각각 독립적으로 실패 가능)
        async let profile = try? await fetchUserProfileUseCase.execute(userId: userId)
        async let hobbiesResult = try? await fetchMyHobbiesUseCase.execute(userId: userId)
        async let activitiesResult = try? await fetchMyActivitiesUseCase.execute(
            hobbyIds: [],
            lastRecordId: nil,
            userId: userId
        )
        async let cardsResult = try? await fetchHobbyCardsUseCase.execute(
            lastHobbyCardId: nil,
            size: 20,
            userId: userId
        )
        async let scrapsResult = try? await fetchScrapsUseCase.execute(
            lastRecordId: nil,
            userId: userId
        )

        let (profileOpt, hobbiesOpt, activitiesOpt, cardsOpt, scrapsOpt) = await (
            profile,
            hobbiesResult,
            activitiesResult,
            cardsResult,
            scrapsResult
        )

        // 성공한 결과만 업데이트
        if let profile = profileOpt {
            self.userProfile = profile
        }

        if let hobbies = hobbiesOpt {
            self.myHobbies = hobbies.hobbies
            self.inProgressHobbyCount = hobbies.inProgressHobbyCount
            self.hobbyCardCount = hobbies.hobbyCardCount
        }

        if let activities = activitiesOpt {
            self.activities = activities.feedList
            self.totalActivityCount = activities.totalFeedCount ?? 0
            self.hasMoreActivities = activities.hasNext
            self.lastRecordId = activities.lastRecordId
        }

        if let cards = cardsOpt {
            self.hobbyCards = cards.cards
            self.hasMoreHobbyCards = cards.hasNext
            self.lastHobbyCardId = cards.lastCardId
        }

        if let scraps = scrapsOpt {
            self.scraps = scraps.feedList
            self.totalScrapCount = scraps.totalFeedCount ?? 0
            self.hasMoreScraps = scraps.hasNext
            self.lastScrapRecordId = scraps.lastRecordId
        }

        self.isLoading = false
    }

    func switchTab(to tab: MyPageTab) {
        currentTab = tab
    }

    func resetHobbyFilter() {
        selectedHobbyIds = []
    }

    func filterByHobbies(hobbyIds: Set<Int>) async {
        selectedHobbyIds = hobbyIds
        lastRecordId = nil
        hasMoreActivities = true

        await refreshActivities()
    }

    func refreshActivities() async {
        isLoading = true

        do {
            let hobbyIdsArray = Array(selectedHobbyIds)

            let result = try await fetchMyActivitiesUseCase.execute(
                hobbyIds: hobbyIdsArray,
                lastRecordId: nil,
                userId: userId
            )

            self.activities = result.feedList
            self.totalActivityCount = result.totalFeedCount ?? 0
            self.hasMoreActivities = result.hasNext
            self.lastRecordId = result.lastRecordId
            self.isLoading = false

        } catch let appError as AppError {
            self.error = appError
            self.isLoading = false
        } catch {
            self.error = .unknown(error)
            self.isLoading = false
        }
    }

    func loadMoreActivities() async {
        guard !isLoadingMore && hasMoreActivities else { return }
        isLoadingMore = true

        do {
            let result = try await fetchMyActivitiesUseCase.execute(
                hobbyIds: Array(selectedHobbyIds),
                lastRecordId: lastRecordId,
                userId: userId
            )

            self.activities.append(contentsOf: result.feedList)
            self.hasMoreActivities = result.hasNext
            self.lastRecordId = result.lastRecordId
            self.isLoadingMore = false

        } catch let appError as AppError {
            self.error = appError
            self.isLoadingMore = false
        } catch {
            self.error = .unknown(error)
            self.isLoadingMore = false
        }
    }

    func refreshScraps() async {
        isLoading = true
        lastScrapRecordId = nil
        hasMoreScraps = true

        do {
            let result = try await fetchScrapsUseCase.execute(
                lastRecordId: nil,
                userId: userId
            )

            self.scraps = result.feedList
            self.totalScrapCount = result.totalFeedCount ?? 0
            self.hasMoreScraps = result.hasNext
            self.lastScrapRecordId = result.lastRecordId
            self.isLoading = false

        } catch let appError as AppError {
            self.error = appError
            self.isLoading = false
        } catch {
            self.error = .unknown(error)
            self.isLoading = false
        }
    }

    func loadMoreScraps() async {
        guard !isLoadingMore && hasMoreScraps else { return }
        isLoadingMore = true

        do {
            let result = try await fetchScrapsUseCase.execute(
                lastRecordId: lastScrapRecordId,
                userId: userId
            )

            self.scraps.append(contentsOf: result.feedList)
            self.hasMoreScraps = result.hasNext
            self.lastScrapRecordId = result.lastRecordId
            self.isLoadingMore = false

        } catch let appError as AppError {
            self.error = appError
            self.isLoadingMore = false
        } catch {
            self.error = .unknown(error)
            self.isLoadingMore = false
        }
    }
}

// MARK: - ProfileViewModelProtocol

extension UserProfileViewModel {
    var activitiesPublisher: Published<[FeedItem]>.Publisher { $activities }
    var totalActivityCountPublisher: Published<Int>.Publisher { $totalActivityCount }
    var myHobbiesPublisher: Published<[MyPageHobby]>.Publisher { $myHobbies }
    var selectedHobbyIdsPublisher: Published<Set<Int>>.Publisher { $selectedHobbyIds }
    var hobbyCardsPublisher: Published<[CompletedHobbyCard]>.Publisher { $hobbyCards }
    var scrapsPublisher: Published<[FeedItem]>.Publisher { $scraps }
    var totalScrapCountPublisher: Published<Int>.Publisher { $totalScrapCount }
    var isLoadingMorePublisher: Published<Bool>.Publisher { $isLoadingMore }
}
