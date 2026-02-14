//
//  AppEventBus.swift
//  Forday
//
//  Created by Subeen on 1/28/26.
//

import Foundation
import Combine

/// Central event bus for app-wide events using Combine
final class AppEventBus {

    /// Shared singleton instance
    static let shared = AppEventBus()

    private init() {}

    // MARK: - Hobby Events

    /// Published when hobby settings (time, frequency, goal days) are updated
    /// Payload: hobbyId of the updated hobby
    let hobbySettingsUpdated = PassthroughSubject<Int, Never>()

    /// Published when a new hobby is created
    /// Payload: hobbyId of the new hobby
    let hobbyCreated = PassthroughSubject<Int, Never>()

    /// Published when a hobby is deleted or archived
    let hobbyDeleted = PassthroughSubject<Void, Never>()

    // MARK: - Activity Record Events

    /// Published when a new activity record is created
    /// Payload: hobbyId that the activity belongs to
    let activityRecordCreated = PassthroughSubject<Int, Never>()

    /// Published when an activity record is deleted
    let activityRecordDeleted = PassthroughSubject<Void, Never>()

    // MARK: - Activity Events

    /// Published when a new activity is created
    /// Payload: hobbyId that the activity belongs to
    let activityCreated = PassthroughSubject<Int, Never>()

    /// Published when an activity is updated
    /// Payload: hobbyId that the activity belongs to
    let activityUpdated = PassthroughSubject<Int, Never>()

    /// Published when an activity is deleted
    /// Payload: hobbyId that the activity belongs to
    let activityDeleted = PassthroughSubject<Int, Never>()

    // MARK: - Scrap Events

    /// Published when scrap status changes (added or removed)
    let scrapDidUpdate = PassthroughSubject<Void, Never>()
}
