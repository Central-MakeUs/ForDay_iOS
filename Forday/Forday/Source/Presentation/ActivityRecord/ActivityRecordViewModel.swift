//
//  ActivityRecordViewModel.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import Foundation
import Combine
import UIKit

class ActivityRecordViewModel {

    // Published Properties

    @Published var selectedActivity: Activity?
    @Published var selectedSticker: Sticker?
    @Published var memo: String = ""
    @Published var privacy: Privacy = .public
    @Published var isSubmitEnabled: Bool = false
    @Published var activities: [Activity] = []
    @Published var uploadedImageUrl: String?
    @Published var selectedImage: UIImage?

    // Mock Data
    let stickers: [Sticker] = [
        Sticker(id: 1, image: .My.smileJpg, type: .smile),
        Sticker(id: 2, image: .My.sadJpg, type: .sad),
        Sticker(id: 3, image: .My.laughJpg, type: .laugh),
        Sticker(id: 4, image: .My.angryJpg, type: .angry)
    ]

    private var cancellables = Set<AnyCancellable>()

    // UseCase
    private let fetchActivityListUseCase: FetchActivityDropdownListUseCase
    private let uploadImageUseCase: UploadImageUseCase
    private let deleteImageUseCase: DeleteImageUseCase
    private let createActivityRecordUseCase: CreateActivityRecordUseCase
    private let updateActivityRecordUseCase: UpdateActivityRecordUseCase

    private let hobbyId: Int
    private let activityDetail: ActivityDetail?

    // MARK: - Public Properties

    /// Current hobby ID for this activity record
    var currentHobbyId: Int {
        return hobbyId
    }

    /// Whether this is in edit mode
    var isEditMode: Bool {
        return activityDetail != nil
    }

    // Initialization

    init(
        hobbyId: Int,
        activityDetail: ActivityDetail? = nil,
        fetchActivityListUseCase: FetchActivityDropdownListUseCase = FetchActivityDropdownListUseCase(),
        uploadImageUseCase: UploadImageUseCase = UploadImageUseCase(),
        deleteImageUseCase: DeleteImageUseCase = DeleteImageUseCase(),
        createActivityRecordUseCase: CreateActivityRecordUseCase = CreateActivityRecordUseCase(),
        updateActivityRecordUseCase: UpdateActivityRecordUseCase = UpdateActivityRecordUseCase()
    ) {
        self.hobbyId = hobbyId
        self.activityDetail = activityDetail
        self.fetchActivityListUseCase = fetchActivityListUseCase
        self.uploadImageUseCase = uploadImageUseCase
        self.deleteImageUseCase = deleteImageUseCase
        self.createActivityRecordUseCase = createActivityRecordUseCase
        self.updateActivityRecordUseCase = updateActivityRecordUseCase
        bind()
        loadExistingData()
    }

    // MARK: - Load Existing Data (for Edit Mode)

    private func loadExistingData() {
        guard let detail = activityDetail else { return }

        // Set memo
        memo = detail.memo

        // Set privacy
        if let privacyType = Privacy(rawValue: detail.visibility) {
            privacy = privacyType
        }

        // Set uploaded image URL
        if !detail.imageUrl.isEmpty {
            uploadedImageUrl = detail.imageUrl
        }

        // Note: selectedActivity and selectedSticker will be set after fetching activity list
        // We'll match them by activityId and sticker filename
    }

    // Methods

    private func bind() {
        Publishers.CombineLatest($selectedActivity, $selectedSticker)
            .sink { [weak self] activity, sticker in
                self?.isSubmitEnabled = activity != nil && sticker != nil
            }
            .store(in: &cancellables)
    }

    func selectSticker(_ sticker: Sticker) {
        selectedSticker = sticker
    }

    func fetchActivityList() async throws {
        let fetchedActivities = try await fetchActivityListUseCase.execute(hobbyId: hobbyId)
        await MainActor.run {
            self.activities = fetchedActivities

            // If in edit mode, select the existing activity
            if let detail = activityDetail,
               let activity = fetchedActivities.first(where: { $0.activityId == detail.activityId }) {
                self.selectedActivity = activity
            }

            // If in edit mode, select the existing sticker
            if let detail = activityDetail,
               let stickerType = StickerType(fileName: detail.sticker),
               let sticker = stickers.first(where: { $0.type == stickerType }) {
                self.selectedSticker = sticker
            }
        }
    }

    func selectActivity(_ activity: Activity) {
        selectedActivity = activity
    }

    func selectPrivacy(_ selectedPrivacy: Privacy) {
        privacy = selectedPrivacy
    }

    func updateMemo(_ text: String) {
        memo = text
    }

    func uploadImage(_ image: UIImage) async throws {
        let imageUrls = try await uploadImageUseCase.execute(images: [(image: image, usage: .activityRecord)])
        await MainActor.run {
            if let firstUrl = imageUrls.first {
                self.uploadedImageUrl = firstUrl
                self.selectedImage = image
            }
        }
    }

    func deleteImage() async throws {
        guard let imageUrl = uploadedImageUrl else { return }
        _ = try await deleteImageUseCase.execute(imageUrl: imageUrl)
        await MainActor.run {
            self.uploadedImageUrl = nil
            self.selectedImage = nil
        }
    }

    func submitActivityRecord() async throws -> ActivityRecord {
        guard let activityId = selectedActivity?.activityId,
              let selectedSticker = selectedSticker else {
            throw ActivityRecordError.missingRequiredFields
        }

        // Convert sticker type to filename for API
        let stickerFileName = selectedSticker.type.rawValue

        if isEditMode {
            guard let recordId = activityDetail?.activityRecordId else {
                throw ActivityRecordError.missingRequiredFields
            }

            // Call update API
            let updateResult = try await updateActivityRecordUseCase.execute(
                recordId: recordId,
                activityId: activityId,
                sticker: stickerFileName,
                memo: memo.isEmpty ? nil : memo,
                imageUrl: uploadedImageUrl,
                visibility: privacy
            )

            // Convert UpdateRecordResult to ActivityRecord for compatibility
            return ActivityRecord(
                message: updateResult.message,
                hobbyId: hobbyId,
                activityRecordId: recordId,
                activityContent: updateResult.activityContent,
                imageUrl: updateResult.imageUrl,
                sticker: updateResult.sticker,
                memo: updateResult.memo,
                extensionCheckRequired: false  // Not applicable for updates
            )
        }

        return try await createActivityRecordUseCase.execute(
            activityId: activityId,
            sticker: stickerFileName,
            memo: memo.isEmpty ? nil : memo,
            imageUrl: uploadedImageUrl,
            visibility: privacy
        )
    }
}

enum ActivityRecordError: Error {
    case missingRequiredFields
}

// Models

struct Sticker {
    let id: Int
    let image: UIImage
    let type: StickerType
}

extension Sticker: Equatable {
    static func == (lhs: Sticker, rhs: Sticker) -> Bool {
        return lhs.id == rhs.id
    }
}
