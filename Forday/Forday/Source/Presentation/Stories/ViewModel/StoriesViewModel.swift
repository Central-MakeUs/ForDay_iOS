//
//  StoriesViewModel.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation
import Combine

final class StoriesViewModel {

    // MARK: - Published Properties

    @Published private(set) var tabs: [StoriesTab] = []
    @Published private(set) var stories: [Story] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var error: AppError?

    @Published private(set) var selectedTabIndex: Int = 0
    @Published private(set) var selectedFilter: StoriesFilter = .all

    private(set) var hasNext: Bool = false
    private(set) var lastRecordId: Int?
    private(set) var currentHobbyId: Int?

    // MARK: - Use Cases

    private let fetchTabsUseCase: FetchStoriesTabsUseCase
    private let fetchStoriesUseCase: FetchStoriesUseCase

    // MARK: - Properties

    private let pageSize: Int = 20

    // MARK: - Initialization

    init(
        fetchTabsUseCase: FetchStoriesTabsUseCase = FetchStoriesTabsUseCase(),
        fetchStoriesUseCase: FetchStoriesUseCase = FetchStoriesUseCase()
    ) {
        self.fetchTabsUseCase = fetchTabsUseCase
        self.fetchStoriesUseCase = fetchStoriesUseCase
    }

    // MARK: - Tab Management

    func loadTabs() async {
        await MainActor.run {
            isLoading = true
        }

        do {
            let loadedTabs = try await fetchTabsUseCase.execute()

            await MainActor.run {
                self.tabs = loadedTabs
                self.error = nil
                self.isLoading = false

                // Auto-select first tab if available
                if !loadedTabs.isEmpty {
                    selectTab(at: 0)
                }
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

    func selectTab(at index: Int) {
        guard index >= 0 && index < tabs.count else { return }

        selectedTabIndex = index
        currentHobbyId = tabs[index].hobbyId

        // Reset pagination
        lastRecordId = nil
        hasNext = false
        stories = []

        // Load stories for selected tab
        Task {
            await loadStories()
        }
    }

    // MARK: - Filter Management

    func selectFilter(_ filter: StoriesFilter) {
        selectedFilter = filter

        // Reset and reload stories
        // Note: Filter API parameters are not yet defined, so this just updates UI state
        lastRecordId = nil
        hasNext = false
        stories = []

        Task {
            await loadStories()
        }
    }

    // MARK: - Stories Loading

    func loadStories() async {
        await MainActor.run {
            isLoading = true
        }

        do {
            let result = try await fetchStoriesUseCase.execute(
                hobbyId: currentHobbyId,
                lastRecordId: nil,
                size: pageSize,
                keyword: nil
            )

            await MainActor.run {
                if let result = result {
                    self.stories = result.stories
                    self.hasNext = result.hasNext
                    self.lastRecordId = result.lastRecordId
                } else {
                    self.stories = []
                    self.hasNext = false
                    self.lastRecordId = nil
                }
                self.error = nil
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

    func loadMore() async {
        guard hasNext, !isLoadingMore, let lastRecordId = lastRecordId else { return }

        await MainActor.run {
            isLoadingMore = true
        }

        do {
            let result = try await fetchStoriesUseCase.execute(
                hobbyId: currentHobbyId,
                lastRecordId: lastRecordId,
                size: pageSize,
                keyword: nil
            )

            await MainActor.run {
                if let result = result {
                    self.stories.append(contentsOf: result.stories)
                    self.hasNext = result.hasNext
                    self.lastRecordId = result.lastRecordId
                }
                self.error = nil
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

    func refresh() async {
        // Reset pagination
        lastRecordId = nil
        hasNext = false
        stories = []

        await loadStories()
    }
}
