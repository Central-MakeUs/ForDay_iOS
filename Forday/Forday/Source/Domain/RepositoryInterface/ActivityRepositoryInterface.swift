//
//  ActivityRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation

protocol ActivityRepositoryInterface {
    func fetchOthersActivities(hobbyId: Int) async throws -> OthersActivityResult
    func fetchAIRecommendations(hobbyId: Int) async throws -> AIRecommendationResult
    func fetchAIActivityItems(hobbyId: Int, type: String) async throws -> AIActivityItemsResult
    func fetchActivityList(hobbyId: Int) async throws -> [Activity]
    func fetchActivityDropdownList(hobbyId: Int, size: Int?) async throws -> [Activity]
    func createActivities(hobbyId: Int, activities: [ActivityInput]) async throws -> String
    func updateActivity(activityId: Int, content: String) async throws -> String
    func deleteActivity(activityId: Int) async throws -> String
    func createActivityRecord(activityId: Int, sticker: String, memo: String?, imageUrl: String?, visibility: Privacy) async throws -> ActivityRecord
    func createActivityRecordV2(
        hobbyId: Int,
        activityId: Int?,
        activityContent: String?,
        sticker: String,
        images: [RecordImageInput],
        visibility: Privacy,
        memo: String?,
        activityContentValid: Bool
    ) async throws -> ActivityRecordV2
    func fetchStickerBoard(hobbyId: Int?, page: Int?, size: Int?) async throws -> StickerBoardResult
    func fetchKeyboardKeywords(hobbyInfoId: Int) async throws -> [KeyboardKeyword]
}

