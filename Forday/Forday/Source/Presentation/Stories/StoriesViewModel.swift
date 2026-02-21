//
//  StoriesViewModel.swift
//  Forday
//
//  Created by Subeen on 2/19/26.
//

import Foundation
import Combine

final class StoriesViewModel {

    // MARK: - Published Properties

    @Published private(set) var tabs: [StoriesTab] = []
    @Published private(set) var stories: [Story] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: AppError?
    @Published private(set) var selectedTabIndex: Int = 0
    @Published private(set) var selectedFilterType: StoryFilterType = .all
    @Published private(set) var hasNext = false
    @Published private(set) var imageSizesUpdated = false  // 이미지 크기 프리페치 완료 시 토글

    // MARK: - Private Properties

    private let fetchStoriesUseCase: FetchStoriesUseCase
    private let addReactionUseCase: AddReactionUseCase
    private let deleteReactionUseCase: DeleteReactionUseCase
    private let imageSizeCache = ImageSizeCache.shared

    private var lastRecordId: Int?
    private var currentHobbyId: Int?
    private var isLoadingMore = false
    private var isInitialLoad = true

    // MARK: - Initialization

    init(
        fetchStoriesUseCase: FetchStoriesUseCase = FetchStoriesUseCase(),
        addReactionUseCase: AddReactionUseCase = AddReactionUseCase(),
        deleteReactionUseCase: DeleteReactionUseCase = DeleteReactionUseCase()
    ) {
        self.fetchStoriesUseCase = fetchStoriesUseCase
        self.addReactionUseCase = addReactionUseCase
        self.deleteReactionUseCase = deleteReactionUseCase
    }

    // MARK: - Public Methods

    /// 초기 데이터 로드 (탭 + 첫 스토리)
    @MainActor
    func loadInitialData() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        isInitialLoad = true

        do {
            // 첫 요청 시 hobbyId = nil → 가장 최근 취미로 조회됨 (탭 정보 포함)
            let result = try await fetchStoriesUseCase.execute(
                hobbyId: nil,
                lastRecordId: nil,
                size: 20,
                keyword: nil,
                filterType: selectedFilterType
            )

            if let result = result {
                // 탭 정보 설정
                if !result.tabs.isEmpty {
                    self.tabs = result.tabs

                    // currentHobby가 true인 탭 찾기
                    if let currentIndex = result.tabs.firstIndex(where: { $0.currentHobby }) {
                        self.selectedTabIndex = currentIndex
                        self.currentHobbyId = result.tabs[currentIndex].hobbyId
                    } else if let firstTab = result.tabs.first {
                        self.selectedTabIndex = 0
                        self.currentHobbyId = firstTab.hobbyId
                    }
                }

                // 스토리 설정
                self.stories = result.stories
                self.lastRecordId = result.lastRecordId
                self.hasNext = result.hasNext

                // 이미지 크기 프리페치
                prefetchImageSizes(for: result.stories)
            }
        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = .unknown(error)
        }

        isLoading = false
        isInitialLoad = false
    }

    /// 탭 선택
    @MainActor
    func selectTab(at index: Int) async {
        guard index < tabs.count, index != selectedTabIndex else { return }

        selectedTabIndex = index
        currentHobbyId = tabs[index].hobbyId

        // 필터 초기화 및 스토리 다시 로드
        selectedFilterType = .all
        await loadStories(reset: true)
    }

    // TODO: 필터 API 완성 후 활성화
    /// 필터 선택
//    @MainActor
//    func selectFilter(_ filterType: StoryFilterType) async {
//        guard filterType != selectedFilterType else { return }
//
//        selectedFilterType = filterType
//        await loadStories(reset: true)
//    }

    /// 스토리 로드
    @MainActor
    func loadStories(reset: Bool = false) async {
        if reset {
            lastRecordId = nil
            stories = []
        }

        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            let result = try await fetchStoriesUseCase.execute(
                hobbyId: currentHobbyId,
                lastRecordId: lastRecordId,
                size: 20,
                keyword: nil,
                filterType: selectedFilterType
            )

            if let result = result {
                if reset {
                    self.stories = result.stories
                } else {
                    self.stories.append(contentsOf: result.stories)
                }
                self.lastRecordId = result.lastRecordId
                self.hasNext = result.hasNext

                // 이미지 크기 프리페치
                prefetchImageSizes(for: result.stories)
            }
        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = .unknown(error)
        }

        isLoading = false
    }

    /// 더 많은 스토리 로드 (무한 스크롤)
    @MainActor
    func loadMoreStoriesIfNeeded(currentIndex: Int) async {
        // 마지막에서 5개 전에 도달하면 더 로드
        guard currentIndex >= stories.count - 5,
              hasNext,
              !isLoading,
              !isLoadingMore else { return }

        isLoadingMore = true
        await loadStories(reset: false)
        isLoadingMore = false
    }

    /// 좋아요 토글
    @MainActor
    func toggleGreat(for recordId: Int) async {
        // 현재 스토리 찾기
        guard let index = stories.firstIndex(where: { $0.recordId == recordId }) else { return }

        let story = stories[index]
        let isCurrentlyPressed = story.pressedAwesome

        do {
            if isCurrentlyPressed {
                // 좋아요 취소
                _ = try await deleteReactionUseCase.execute(recordId: recordId, reactionType: .great)
            } else {
                // 좋아요 추가
                _ = try await addReactionUseCase.execute(recordId: recordId, reactionType: .great)
            }

            // UI 업데이트 - 새로운 Story 객체로 교체
            var updatedStories = stories
            let updatedStory = Story(
                recordId: story.recordId,
                thumbnailUrl: story.thumbnailUrl,
                stickerType: story.stickerType,
                title: story.title,
                memo: story.memo,
                userInfo: story.userInfo,
                pressedAwesome: !isCurrentlyPressed
            )
            updatedStories[index] = updatedStory
            self.stories = updatedStories

        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = .unknown(error)
        }
    }

    /// 현재 선택된 취미명
    var currentHobbyName: String? {
        guard selectedTabIndex < tabs.count else { return nil }
        return tabs[selectedTabIndex].hobbyName
    }

    /// 스토리 이미지 크기 반환 (캐시된 값)
    func getImageSize(for story: Story) -> CGSize? {
        guard let url = story.thumbnailUrl, !url.isEmpty else { return nil }
        return imageSizeCache.getSize(for: url)
    }

    // MARK: - Private Methods

    /// 스토리 목록의 이미지 크기 프리페치
    private func prefetchImageSizes(for stories: [Story]) {
        let urls = stories.compactMap { $0.thumbnailUrl }.filter { !$0.isEmpty }
        guard !urls.isEmpty else { return }

        imageSizeCache.prefetchSizes(for: urls) { [weak self] in
            self?.imageSizesUpdated.toggle()  // 레이아웃 갱신 트리거
        }
    }
}
