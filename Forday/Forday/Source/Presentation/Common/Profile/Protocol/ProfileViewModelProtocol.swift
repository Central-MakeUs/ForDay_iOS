//
//  ProfileViewModelProtocol.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import Foundation
import Combine

/// MyPageViewModel과 UserProfileViewModel이 공유하는 프로토콜
/// ActivityGridViewController, HobbyCardStackViewController, ScrapGridViewController 등에서 사용
protocol ProfileViewModelProtocol: AnyObject {
    // MARK: - Published Properties (읽기 전용)

    // Activities
    var activitiesPublisher: Published<[FeedItem]>.Publisher { get }
    var totalActivityCountPublisher: Published<Int>.Publisher { get }
    var myHobbiesPublisher: Published<[MyPageHobby]>.Publisher { get }
    var selectedHobbyIdsPublisher: Published<Set<Int>>.Publisher { get }

    // Hobby Cards
    var hobbyCardsPublisher: Published<[CompletedHobbyCard]>.Publisher { get }

    // Scraps
    var scrapsPublisher: Published<[FeedItem]>.Publisher { get }
    var totalScrapCountPublisher: Published<Int>.Publisher { get }

    // Loading State
    var isLoadingMorePublisher: Published<Bool>.Publisher { get }

    // MARK: - Properties

    var activities: [FeedItem] { get }
    var scraps: [FeedItem] { get }
    var isLoadingMore: Bool { get }

    // MARK: - Methods

    func filterByHobbies(hobbyIds: Set<Int>) async
    func loadMoreActivities() async
    func loadMoreScraps() async
    func refreshScraps() async
}
