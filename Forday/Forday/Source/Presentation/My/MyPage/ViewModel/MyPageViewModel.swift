//
//  MyPageViewModel.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation
import Combine

enum MyPageTab {
    case activities
    case hobbyCards
    case scraps
}

final class MyPageViewModel {

    // MARK: - Published Properties

    @Published var userProfile: UserInfo?
    @Published var currentTab: MyPageTab = .activities
    @Published var myHobbies: [MyPageHobby] = []
    @Published var inProgressHobbyCount: Int = 0  // Segment "진행 중(n)" 표시용
    @Published var hobbyCardCount: Int = 0        // Segment "취미 카드(n)" 표시용
    @Published var activities: [FeedItem] = []
    @Published var hobbyCards: [CompletedHobbyCard] = []
    @Published var scraps: [FeedItem] = []
    @Published var selectedHobbyIds: Set<Int> = [] // Empty = all hobbies
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var error: AppError?

    // MARK: - Private Properties

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
        fetchUserProfileUseCase: FetchUserProfileUseCase = FetchUserProfileUseCase(),
        fetchMyActivitiesUseCase: FetchMyActivitiesUseCase = FetchMyActivitiesUseCase(),
        fetchMyHobbiesUseCase: FetchMyHobbiesUseCase = FetchMyHobbiesUseCase(),
        fetchHobbyCardsUseCase: FetchHobbyCardsUseCase = FetchHobbyCardsUseCase(),
        fetchScrapsUseCase: FetchScrapsUseCase = FetchScrapsUseCase()
    ) {
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.fetchMyActivitiesUseCase = fetchMyActivitiesUseCase
        self.fetchMyHobbiesUseCase = fetchMyHobbiesUseCase
        self.fetchHobbyCardsUseCase = fetchHobbyCardsUseCase
        self.fetchScrapsUseCase = fetchScrapsUseCase
    }

    // MARK: - Public Methods

    /// 게스트 유저 여부 확인
    var isGuestUser: Bool {
        return TokenStorage.shared.loadGuestUserId() != nil
    }

    func fetchInitialData() async {
        // 게스트 유저는 API 호출 스킵 (마이페이지 데이터 불필요)
        guard !isGuestUser else {
            await MainActor.run {
                self.isLoading = false
            }
            return
        }

        await MainActor.run {
            isLoading = true
        }

        // Fetch all data in parallel, each can fail independently
        async let profile = try? await fetchUserProfileUseCase.execute()
        async let hobbiesResult = try? await fetchMyHobbiesUseCase.execute()
        async let activitiesResult = try? await fetchMyActivitiesUseCase.execute(hobbyIds: [], lastRecordId: nil)
        async let cardsResult = try? await fetchHobbyCardsUseCase.execute(lastHobbyCardId: nil, size: 20)

        let (profileOpt, hobbiesOpt, activitiesOpt, cardsOpt) = await (
            profile,
            hobbiesResult,
            activitiesResult,
            cardsResult
        )

        await MainActor.run {
            // Update only successful results
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
                self.hasMoreActivities = activities.hasNext
                self.lastRecordId = activities.lastRecordId
            }

            if let cards = cardsOpt {
                self.hobbyCards = cards.cards
                self.hasMoreHobbyCards = cards.hasNext
                self.lastHobbyCardId = cards.lastCardId
            }

            self.isLoading = false
        }
    }

    func switchTab(to tab: MyPageTab) {
        currentTab = tab
    }

    func filterByHobbies(hobbyIds: Set<Int>) async {
        guard !isGuestUser else { return }

        await MainActor.run {
            selectedHobbyIds = hobbyIds
            lastRecordId = nil
            hasMoreActivities = true
        }

        await refreshActivities()
    }

    func refreshActivities() async {
        guard !isGuestUser else { return }

        await MainActor.run {
            isLoading = true
        }

        do {
            let hobbyIdsArray = Array(selectedHobbyIds)

            let result = try await fetchMyActivitiesUseCase.execute(
                hobbyIds: hobbyIdsArray,
                lastRecordId: nil
            )

            await MainActor.run {
                self.activities = result.feedList
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
        guard !isGuestUser, !isLoadingMore && hasMoreActivities else { return }

        await MainActor.run {
            isLoadingMore = true
        }

        do {
            let result = try await fetchMyActivitiesUseCase.execute(
                hobbyIds: Array(selectedHobbyIds),
                lastRecordId: lastRecordId
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

    // MARK: - Refresh Individual Data

    func refreshUserProfile() async {
        guard !isGuestUser else { return }

        do {
            let profile = try await fetchUserProfileUseCase.execute()
            await MainActor.run {
                self.userProfile = profile
            }
        } catch {
            // Silently fail - user can refresh manually if needed
            print("❌ Failed to refresh user profile: \(error)")
        }
    }

    func refreshHobbies() async {
        guard !isGuestUser else { return }

        do {
            let hobbies = try await fetchMyHobbiesUseCase.execute()
            await MainActor.run {
                self.myHobbies = hobbies.hobbies
                self.inProgressHobbyCount = hobbies.inProgressHobbyCount
                self.hobbyCardCount = hobbies.hobbyCardCount
            }
        } catch {
            // Silently fail - user can refresh manually if needed
            print("❌ Failed to refresh hobbies: \(error)")
        }
    }

    func refreshScraps() async {
        guard !isGuestUser else { return }

        await MainActor.run {
            isLoading = true
        }

        do {
            let result = try await fetchScrapsUseCase.execute(lastRecordId: nil)

            await MainActor.run {
                self.scraps = result.feedList
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
        guard !isGuestUser, !isLoadingMore && hasMoreScraps else { return }

        await MainActor.run {
            isLoadingMore = true
        }

        do {
            let result = try await fetchScrapsUseCase.execute(lastRecordId: lastScrapRecordId)

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
