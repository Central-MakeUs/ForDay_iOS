//
//  ActivityRecordViewModel.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import Foundation
import Combine
import UIKit
import Kingfisher

class ActivityRecordViewModel {

    // Published Properties

    @Published var hobbyChips: [HobbyChip] = []
    @Published var selectedHobbyId: Int?
    @Published var selectedActivity: Activity?

    /// 화면에 표시할 취미 칩 목록 (수정 모드: 선택된 것만, 생성 모드: 전체)
    var displayedHobbyChips: [HobbyChip] {
        // 수정 모드에서는 loadExistingData()에서 이미 1개만 설정했으므로 전체 반환
        return hobbyChips
    }
    @Published var selectedSticker: Sticker?
    @Published var memo: String = ""
    @Published var privacy: Privacy = .public
    @Published var isSubmitEnabled: Bool = false
    @Published var activities: [Activity] = []
    @Published var selectedImage: UIImage?
    @Published var isUploading: Bool = false

    // 이미지 관리 (수정 모드에서 기존 이미지와 새 이미지 구분)
    /// 수정 모드 진입 시 기존 이미지 URL (변경 불가)
    private(set) var originalImageUrl: String?
    /// 새로 업로드한 이미지 URL
    private(set) var newlyUploadedImageUrl: String?
    /// 기존 이미지가 삭제되었는지 여부
    private(set) var isOriginalImageDeleted: Bool = false

    /// API 호출 시 사용할 최종 이미지 URL
    var currentImageUrl: String? {
        // 새로 업로드한 이미지가 있으면 그것을 사용
        if let newUrl = newlyUploadedImageUrl {
            return newUrl
        }
        // 기존 이미지가 삭제되었으면 nil
        if isOriginalImageDeleted {
            return nil
        }
        // 기존 이미지 URL 반환
        return originalImageUrl
    }

    /// 새로 업로드한 이미지 URL (외부에서 참조용)
    var uploadedImageUrl: String? {
        return newlyUploadedImageUrl
    }

    // Mock Data
    let stickers: [Sticker] = [
        Sticker(id: 1, image: .My.smileJpg, type: .smile),
        Sticker(id: 2, image: .My.sadJpg, type: .sad),
        Sticker(id: 3, image: .My.laughJpg, type: .laugh),
        Sticker(id: 4, image: .My.angryJpg, type: .angry)
    ]

    private var cancellables = Set<AnyCancellable>()

    // UseCase
    private let fetchHobbyChipsUseCase: FetchHobbyChipsUseCase
    private let fetchActivityListUseCase: FetchActivityDropdownListUseCase
    private let uploadImageUseCase: UploadImageUseCase
    private let deleteImageUseCase: DeleteImageUseCase
    private let createActivityRecordUseCase: CreateActivityRecordUseCase
    private let updateActivityRecordUseCase: UpdateActivityRecordUseCase

    private let hobbyId: Int
    private let activityDetail: ActivityDetail?
    private let preselectedActivityId: Int?

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
        preselectedActivityId: Int? = nil,
        fetchHobbyChipsUseCase: FetchHobbyChipsUseCase = FetchHobbyChipsUseCase(),
        fetchActivityListUseCase: FetchActivityDropdownListUseCase = FetchActivityDropdownListUseCase(),
        uploadImageUseCase: UploadImageUseCase = UploadImageUseCase(),
        deleteImageUseCase: DeleteImageUseCase = DeleteImageUseCase(),
        createActivityRecordUseCase: CreateActivityRecordUseCase = CreateActivityRecordUseCase(),
        updateActivityRecordUseCase: UpdateActivityRecordUseCase = UpdateActivityRecordUseCase()
    ) {
        self.hobbyId = hobbyId
        self.activityDetail = activityDetail
        self.preselectedActivityId = preselectedActivityId
        self.fetchHobbyChipsUseCase = fetchHobbyChipsUseCase
        self.fetchActivityListUseCase = fetchActivityListUseCase
        self.uploadImageUseCase = uploadImageUseCase
        self.deleteImageUseCase = deleteImageUseCase
        self.createActivityRecordUseCase = createActivityRecordUseCase
        self.updateActivityRecordUseCase = updateActivityRecordUseCase
        self.selectedHobbyId = hobbyId
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

        // Set original image URL (수정 모드에서 기존 이미지 URL 저장)
        if !detail.imageUrl.isEmpty {
            originalImageUrl = detail.imageUrl
        }

        // 수정 모드: 현재 취미 칩만 생성
        let currentHobbyChip = HobbyChip(
            hobbyId: detail.hobbyId,
            hobbyName: detail.hobbyName,
            todayRecorded: false  // 수정 모드에서는 의미 없음
        )
        hobbyChips = [currentHobbyChip]

        // Note: selectedActivity and selectedSticker will be set after fetching activity list
        // We'll match them by activityId and sticker filename
    }

    /// 수정 모드에서 기존 이미지를 Kingfisher로 로드
    func loadOriginalImage() async {
        guard let imageUrl = originalImageUrl,
              let url = URL(string: imageUrl) else { return }

        do {
            let result = try await KingfisherManager.shared.retrieveImage(with: url)
            await MainActor.run {
                self.selectedImage = result.image
            }
        } catch {
            print("❌ 기존 이미지 로드 실패: \(error)")
        }
    }

    // Methods

    private func bind() {
        Publishers.CombineLatest3($selectedActivity, $selectedSticker, $isUploading)
            .sink { [weak self] activity, sticker, isUploading in
                self?.isSubmitEnabled = activity != nil && sticker != nil && !isUploading
            }
            .store(in: &cancellables)
    }

    func selectSticker(_ sticker: Sticker) {
        selectedSticker = sticker
    }

    func fetchHobbyChips() async throws {
        let fetchedChips = try await fetchHobbyChipsUseCase.execute(status: "IN_PROGRESS")
        await MainActor.run {
            self.hobbyChips = fetchedChips
        }
    }

    func selectHobbyChip(_ hobbyChip: HobbyChip) {
        // Don't allow selection of already recorded hobbies
        guard !hobbyChip.todayRecorded else { return }

        selectedHobbyId = hobbyChip.hobbyId
        // Clear selected activity when hobby changes
        selectedActivity = nil
    }

    func fetchActivityList() async throws {
        // Use selected hobby ID from chip selection, fallback to initial hobbyId
        let targetHobbyId = selectedHobbyId ?? hobbyId
        let fetchedActivities = try await fetchActivityListUseCase.execute(hobbyId: targetHobbyId)
        await MainActor.run {
            self.activities = fetchedActivities

            // If in edit mode, select the existing activity
            if let detail = activityDetail,
               let activity = fetchedActivities.first(where: { $0.activityId == detail.activityId }) {
                self.selectedActivity = activity
            }
            // If preselected activity ID is provided (from Home dropdown), select it
            else if let preselectedId = preselectedActivityId,
                    let activity = fetchedActivities.first(where: { $0.activityId == preselectedId }) {
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
        await MainActor.run {
            self.isUploading = true
        }

        defer {
            Task { @MainActor in
                self.isUploading = false
            }
        }

        let imageUrls = try await uploadImageUseCase.execute(images: [(image: image, usage: .activityRecord)])
        await MainActor.run {
            if let firstUrl = imageUrls.first {
                self.newlyUploadedImageUrl = firstUrl
                self.selectedImage = image
                // 새 이미지를 업로드하면 기존 이미지 삭제 상태는 유지 (나중에 수정 완료 시 기존 이미지 삭제)
            }
        }
    }

    /// 화면에서 이미지 제거 (x 버튼 클릭 시)
    /// - 수정 모드: 기존 이미지 삭제 표시만, 새로 업로드한 이미지가 있으면 S3에서 삭제
    /// - 생성 모드: 새로 업로드한 이미지를 S3에서 삭제
    func removeImageFromUI() async throws {
        // 새로 업로드한 이미지가 있으면 S3에서 삭제
        if let newImageUrl = newlyUploadedImageUrl {
            _ = try await deleteImageUseCase.execute(imageUrl: newImageUrl)
        }

        await MainActor.run {
            // 새로 업로드한 이미지 URL 초기화
            self.newlyUploadedImageUrl = nil
            // UI에서 이미지 제거
            self.selectedImage = nil
            // 수정 모드에서 기존 이미지가 있었다면 삭제 표시
            if self.isEditMode && self.originalImageUrl != nil {
                self.isOriginalImageDeleted = true
            }
        }
    }

    /// 기존 이미지를 S3에서 삭제 (수정 완료 시 호출)
    func deleteOriginalImageIfNeeded() async throws {
        // 기존 이미지가 있고, 변경되었거나 삭제되었을 때만 S3에서 삭제
        guard isEditMode,
              let originalUrl = originalImageUrl,
              (newlyUploadedImageUrl != nil || isOriginalImageDeleted) else {
            return
        }

        _ = try await deleteImageUseCase.execute(imageUrl: originalUrl)
        print("✅ 기존 이미지 S3에서 삭제 완료")
    }

    /// 새로 업로드한 이미지 S3 삭제 (수정 취소 시 호출)
    func deleteNewlyUploadedImageIfNeeded() async throws {
        guard let newImageUrl = newlyUploadedImageUrl else { return }

        _ = try await deleteImageUseCase.execute(imageUrl: newImageUrl)
        await MainActor.run {
            self.newlyUploadedImageUrl = nil
        }
        print("✅ 새로 업로드한 이미지 S3에서 삭제 완료")
    }

    /// 기존 deleteImage 메서드 (호환성 유지)
    @available(*, deprecated, message: "Use removeImageFromUI() instead")
    func deleteImage() async throws {
        try await removeImageFromUI()
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

            // Call update API (currentImageUrl: 새 이미지 or 기존 이미지 or nil)
            let updateResult = try await updateActivityRecordUseCase.execute(
                recordId: recordId,
                activityId: activityId,
                sticker: stickerFileName,
                memo: memo.isEmpty ? nil : memo,
                imageUrl: currentImageUrl,
                visibility: privacy
            )


            // 수정 완료 후 기존 이미지가 변경/삭제되었으면 S3에서 삭제
            try await deleteOriginalImageIfNeeded()
            // 수정 완료 후 기존 이미지 정리(비치명 처리)
            do {
                try await deleteOriginalImageIfNeeded()
            } catch {
                // cleanup 실패는 제출 성공을 뒤집지 않음 (로깅/모니터링만)
            }

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
            imageUrl: newlyUploadedImageUrl,
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
