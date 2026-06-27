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
    @Published var activityName: String = ""

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
    /// 선택된 이미지들 (최대 5장)
    /// - TODO: API 수정 후 다중 이미지 업로드 지원 예정. 현재는 첫 번째 이미지만 S3에 업로드됨
    @Published var selectedImages: [UIImage] = []
    @Published var isUploading: Bool = false

    /// 최대 사진 개수
    static let maxPhotoCount = 5

    // MARK: - V2 이미지 관리 (다중 이미지 지원)

    /// 업로드된 이미지 정보 (URL + 크기)
    struct UploadedImageInfo {
        let url: String
        let width: Int
        let height: Int
    }

    /// 업로드된 이미지 정보 배열 (순서 유지)
    private(set) var uploadedImages: [UploadedImageInfo] = []

    // 이미지 관리 (수정 모드에서 기존 이미지와 새 이미지 구분)
    /// 수정 모드 진입 시 기존 이미지 URL (변경 불가)
    private(set) var originalImageUrl: String?
    /// 새로 업로드한 이미지 URL (V1 호환용)
    private(set) var newlyUploadedImageUrl: String?
    /// 기존 이미지가 삭제되었는지 여부
    private(set) var isOriginalImageDeleted: Bool = false

    /// API 호출 시 사용할 최종 이미지 URL (V1 호환용)
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
        Sticker(id: 3, image: .My.laughJpg, type: .laugh),
        Sticker(id: 1, image: .My.smileJpg, type: .smile),
        Sticker(id: 4, image: .My.angryJpg, type: .angry),
        Sticker(id: 2, image: .My.sadJpg, type: .sad)
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

        // Set activity name
        activityName = detail.activityContent

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
                self.selectedImages = [result.image]
            }
        } catch {
            print("❌ 기존 이미지 로드 실패: \(error)")
        }
    }

    // Methods

    private func bind() {
        Publishers.CombineLatest3($activityName, $selectedSticker, $isUploading)
            .sink { [weak self] activityName, sticker, isUploading in
                self?.isSubmitEnabled = !activityName.isEmpty && sticker != nil && !isUploading
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

    /// 로컬에서 취미 칩 추가 (API 미연결)
    /// - Parameter name: 추가할 취미 이름
    /// - Note: TODO - API 연결 필요. 현재는 로컬에서만 추가되며 음수 ID 사용
    func addLocalHobbyChip(name: String) {
        // 중복 체크 (이름 기준)
        guard !hobbyChips.contains(where: { $0.hobbyName == name }) else {
            print("⚠️ 이미 존재하는 취미입니다: \(name)")
            return
        }

        // 로컬 ID 생성 (음수로 서버 ID와 충돌 방지)
        // TODO: API 연결 시 서버에서 받은 ID로 교체 필요
        let localId = -(hobbyChips.count + 1)

        let newChip = HobbyChip(
            hobbyId: localId,
            hobbyName: name,
            todayRecorded: false
        )

        // 배열 끝에 추가
        hobbyChips.append(newChip)

        // 새로 추가한 칩 자동 선택
        selectedHobbyId = localId
        selectedActivity = nil

        print("✅ 로컬 취미 칩 추가됨: \(name) (ID: \(localId))")
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

    func updateActivityName(_ text: String) {
        activityName = text
    }

    /// 이미지 추가 (갤러리에서 선택 시) - V2 API 지원
    /// - Parameter images: 추가할 이미지 배열
    /// - Note: 모든 이미지를 S3에 업로드하고 크기 정보도 함께 저장
    func addImages(_ images: [UIImage]) async throws {
        // 최대 개수 제한
        let availableSlots = Self.maxPhotoCount - selectedImages.count
        guard availableSlots > 0 else { return }

        let imagesToAdd = Array(images.prefix(availableSlots))

        await MainActor.run {
            self.isUploading = true
        }

        defer {
            Task { @MainActor in
                self.isUploading = false
            }
        }

        // 오른쪽 끝에 이미지 추가
        await MainActor.run {
            self.selectedImages.append(contentsOf: imagesToAdd)
        }

        // 모든 새 이미지를 S3에 업로드
        let uploadInputs = imagesToAdd.map { (image: $0, usage: ImageUsage.activityRecord) }
        let imageUrls = try await uploadImageUseCase.execute(images: uploadInputs)

        await MainActor.run {
            // V1 호환용 - 첫 번째 이미지 URL 저장
            if self.newlyUploadedImageUrl == nil, let firstUrl = imageUrls.first {
                self.newlyUploadedImageUrl = firstUrl
            }

            // V2용 - 모든 이미지 정보 저장 (URL + 크기)
            for (index, url) in imageUrls.enumerated() {
                if index < imagesToAdd.count {
                    let image = imagesToAdd[index]
                    let info = UploadedImageInfo(
                        url: url,
                        width: Int(image.size.width),
                        height: Int(image.size.height)
                    )
                    self.uploadedImages.append(info)
                }
            }
        }
    }

    /// 특정 인덱스의 이미지 삭제
    /// - Parameter index: 삭제할 이미지의 인덱스
    func removeImage(at index: Int) async throws {
        guard index >= 0, index < selectedImages.count else { return }

        // 해당 인덱스의 이미지 URL이 있으면 S3에서 삭제
        if index < uploadedImages.count {
            let imageUrl = uploadedImages[index].url
            _ = try await deleteImageUseCase.execute(imageUrl: imageUrl)
        }

        await MainActor.run {
            self.selectedImages.remove(at: index)

            // uploadedImages에서도 제거
            if index < self.uploadedImages.count {
                self.uploadedImages.remove(at: index)
            }

            // V1 호환용 - 첫 번째 이미지 URL 업데이트
            self.newlyUploadedImageUrl = self.uploadedImages.first?.url

            // 수정 모드에서 기존 이미지가 있었다면 삭제 표시
            if self.isEditMode && self.originalImageUrl != nil && self.selectedImages.isEmpty {
                self.isOriginalImageDeleted = true
            }
        }
    }

    /// 이미지 순서 변경
    /// - Parameters:
    ///   - fromIndex: 이동할 이미지의 현재 인덱스
    ///   - toIndex: 이동할 위치의 인덱스
    func moveImage(from fromIndex: Int, to toIndex: Int) {
        guard fromIndex != toIndex,
              fromIndex >= 0, fromIndex < selectedImages.count,
              toIndex >= 0, toIndex < selectedImages.count else { return }

        let image = selectedImages.remove(at: fromIndex)
        selectedImages.insert(image, at: toIndex)

        // uploadedImages 순서도 함께 변경
        if fromIndex < uploadedImages.count && toIndex < uploadedImages.count {
            let info = uploadedImages.remove(at: fromIndex)
            uploadedImages.insert(info, at: toIndex)
        }

        // V1 호환용 - 첫 번째 이미지 URL 업데이트
        newlyUploadedImageUrl = uploadedImages.first?.url
    }

    /// 기존 uploadImage 메서드 (호환성 유지)
    @available(*, deprecated, message: "Use addImages(_:) instead")
    func uploadImage(_ image: UIImage) async throws {
        try await addImages([image])
    }

    /// 모든 이미지 제거 (deprecated - removeImage(at:) 사용 권장)
    /// - 수정 모드: 기존 이미지 삭제 표시, 새로 업로드한 이미지가 있으면 S3에서 삭제
    /// - 생성 모드: 새로 업로드한 이미지를 S3에서 삭제
    @available(*, deprecated, message: "Use removeImage(at:) instead")
    func removeImageFromUI() async throws {
        // 새로 업로드한 이미지가 있으면 S3에서 삭제
        if let newImageUrl = newlyUploadedImageUrl {
            _ = try await deleteImageUseCase.execute(imageUrl: newImageUrl)
        }

        await MainActor.run {
            // 새로 업로드한 이미지 URL 초기화
            self.newlyUploadedImageUrl = nil
            // UI에서 모든 이미지 제거
            self.selectedImages.removeAll()
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

    /// V1 API (deprecated)
    @available(*, deprecated, message: "Use submitActivityRecordV2 instead")
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

    /// V2 API - 다중 이미지 지원, 새 활동 생성 지원
    /// - Returns: ActivityRecordV2
    /// - Note: activityId가 있으면 기존 활동 사용, 없으면 activityName으로 새 활동 생성
    func submitActivityRecordV2() async throws -> ActivityRecordV2 {
        guard let selectedSticker = selectedSticker else {
            throw ActivityRecordError.missingRequiredFields
        }

        // 활동 이름이 비어있으면 에러
        guard !activityName.isEmpty else {
            throw ActivityRecordError.missingRequiredFields
        }

        // Convert sticker type to filename for API
        let stickerFileName = selectedSticker.type.rawValue

        // 이미지 배열 생성 (순서 포함)
        let imageInputs: [RecordImageInput] = uploadedImages.enumerated().map { index, info in
            RecordImageInput(
                imageUrl: info.url,
                imageOrder: index + 1,  // 1부터 시작
                imageWidth: info.width,
                imageHeight: info.height
            )
        }

        // activityId가 있으면 기존 활동 사용, 없으면 activityName으로 새 활동 생성
        let activityId = selectedActivity?.activityId
        let activityContent: String? = (activityId == nil) ? activityName : nil

        // activityId도 없고 activityContent도 비어있으면 에러
        if activityId == nil && (activityContent?.isEmpty ?? true) {
            throw ActivityRecordError.missingRequiredFields
        }

        let result = try await createActivityRecordUseCase.executeV2(
            hobbyId: hobbyId,
            activityId: activityId,
            activityContent: activityContent,
            sticker: stickerFileName,
            images: imageInputs,
            visibility: privacy,
            memo: memo.isEmpty ? nil : memo,
            activityContentValid: true
        )

        return result
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
