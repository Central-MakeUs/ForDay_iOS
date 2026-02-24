//
//  UserProfileViewModel.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import Foundation
import Combine

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
        await MainActor.run {
            isLoading = true
        }

        var fetchErrors: [Error] = []

        // Profile fetch with error tracking
        let profileResult: UserInfo?
        do {
            profileResult = try await fetchUserProfileUseCase.execute(userId: userId)
        } catch {
            profileResult = nil
            fetchErrors.append(error)
        }

        // Hobbies fetch with error tracking
        let hobbiesResult: MyHobbiesResult?
        do {
            hobbiesResult = try await fetchMyHobbiesUseCase.execute(userId: userId)
        } catch {
            hobbiesResult = nil
            fetchErrors.append(error)
        }

        // Activities fetch with error tracking
        let activitiesResult: FeedResult?
        do {
            activitiesResult = try await fetchMyActivitiesUseCase.execute(
                hobbyIds: [],
                lastRecordId: nil,
                userId: userId
            )
        } catch {
            activitiesResult = nil
            fetchErrors.append(error)
        }

        // Cards fetch with error tracking
        let cardsResult: HobbyCardsResult?
        do {
            cardsResult = try await fetchHobbyCardsUseCase.execute(
                lastHobbyCardId: nil,
                size: 20,
                userId: userId
            )
        } catch {
            cardsResult = nil
            fetchErrors.append(error)
        }

        // Scraps fetch with error tracking
        let scrapsResult: FeedResult?
        do {
            scrapsResult = try await fetchScrapsUseCase.execute(
                lastRecordId: nil,
                userId: userId
            )
        } catch {
            scrapsResult = nil
            fetchErrors.append(error)
        }

        await MainActor.run {
            if let profile = profileResult {
                self.userProfile = profile
            }

            if let hobbies = hobbiesResult {
                self.myHobbies = hobbies.hobbies
                self.inProgressHobbyCount = hobbies.inProgressHobbyCount
                self.hobbyCardCount = hobbies.hobbyCardCount
            }

            if let activities = activitiesResult {
                self.activities = activities.feedList
                self.totalActivityCount = activities.totalFeedCount ?? 0
                self.hasMoreActivities = activities.hasNext
                self.lastRecordId = activities.lastRecordId
            }

            if let cards = cardsResult {
                self.hobbyCards = cards.cards
                self.hasMoreHobbyCards = cards.hasNext
                self.lastHobbyCardId = cards.lastCardId
            }

            if let scraps = scrapsResult {
                self.scraps = scraps.feedList
                self.totalScrapCount = scraps.totalFeedCount ?? 0
                self.hasMoreScraps = scraps.hasNext
                self.lastScrapRecordId = scraps.lastRecordId
            }

            // Profile fetch failure is critical - show error to user
            if profileResult == nil, let firstError = fetchErrors.first {
                if let appError = firstError as? AppError {
                    self.error = appError
                } else {
                    self.error = .unknown(firstError)
                }
            }

            self.isLoading = false
        }
    }

    func switchTab(to tab: MyPageTab) {
        currentTab = tab
    }

    func resetHobbyFilter() {
        selectedHobbyIds = []
    }

    func filterByHobbies(hobbyIds: Set<Int>) async {
        await MainActor.run {
            selectedHobbyIds = hobbyIds
            lastRecordId = nil
            hasMoreActivities = true
        }

        await refreshActivities()
    }

    func refreshActivities() async {
        await MainActor.run {
            isLoading = true
        }

        do {
            let hobbyIdsArray = Array(selectedHobbyIds)

            let result = try await fetchMyActivitiesUseCase.execute(
                hobbyIds: hobbyIdsArray,
                lastRecordId: nil,
                userId: userId
            )

            await MainActor.run {
                self.activities = result.feedList
                self.totalActivityCount = result.totalFeedCount ?? 0
                self.hasMoreActivities = result.hasNext
                self.lastRecordId = result.lastRecordId
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

    func loadMoreActivities() async {
        // Atomic check-and-set on MainActor to prevent race conditions
        let shouldProceed = await MainActor.run {
            guard !isLoadingMore && hasMoreActivities else { return false }
            isLoadingMore = true
            return true
        }

        guard shouldProceed else { return }

        do {
            let result = try await fetchMyActivitiesUseCase.execute(
                hobbyIds: Array(selectedHobbyIds),
                lastRecordId: lastRecordId,
                userId: userId
            )

            await MainActor.run {
                self.activities.append(contentsOf: result.feedList)
                self.hasMoreActivities = result.hasNext
                self.lastRecordId = result.lastRecordId
                self.isLoadingMore = false
            }

        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
                self.isLoadingMore = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
                self.isLoadingMore = false
            }
        }
    }

    func refreshScraps() async {
        await MainActor.run {
            isLoading = true
            lastScrapRecordId = nil
            hasMoreScraps = true
        }

        do {
            let result = try await fetchScrapsUseCase.execute(
                lastRecordId: nil,
                userId: userId
            )

            await MainActor.run {
                self.scraps = result.feedList
                self.totalScrapCount = result.totalFeedCount ?? 0
                self.hasMoreScraps = result.hasNext
                self.lastScrapRecordId = result.lastRecordId
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

    func loadMoreScraps() async {
        // Atomic check-and-set on MainActor to prevent race conditions
        let shouldProceed = await MainActor.run {
            guard !isLoadingMore && hasMoreScraps else { return false }
            isLoadingMore = true
            return true
        }

        guard shouldProceed else { return }

        do {
            let result = try await fetchScrapsUseCase.execute(
                lastRecordId: lastScrapRecordId,
                userId: userId
            )

            await MainActor.run {
                self.scraps.append(contentsOf: result.feedList)
                self.hasMoreScraps = result.hasNext
                self.lastScrapRecordId = result.lastRecordId
                self.isLoadingMore = false
            }

        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
                self.isLoadingMore = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
                self.isLoadingMore = false
            }
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
