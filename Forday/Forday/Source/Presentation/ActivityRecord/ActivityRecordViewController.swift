//
//  ActivityRecordViewController.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import Combine
import PhotosUI
import SnapKit
import AVFoundation

class ActivityRecordViewController: UIViewController {

    // Properties

    private let recordView = ActivityRecordView()
    private let viewModel: ActivityRecordViewModel
    private let hobbyName: String
    private var cancellables = Set<AnyCancellable>()
    private var privacyDropdownView: PrivacyDropdownView?
    private var didSubmitSuccessfully = false

    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // Initialization

    init(hobbyId: Int, hobbyName: String, activityDetail: ActivityDetail? = nil, preselectedActivityId: Int? = nil) {
        self.viewModel = ActivityRecordViewModel(
            hobbyId: hobbyId,
            activityDetail: activityDetail,
            preselectedActivityId: preselectedActivityId
        )
        self.hobbyName = hobbyName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Lifecycle

    override func loadView() {
        view = recordView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        bind()
        setupForEditMode()
        // 수정 모드가 아닐 때만 취미 칩 목록 가져오기 (수정 모드는 현재 취미만 표시)
        if !viewModel.isEditMode {
            fetchHobbyChips()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deleteUploadedImageIfNeeded()
    }

    private func deleteUploadedImageIfNeeded() {
        // 제출 성공한 경우 이미지 삭제하지 않음
        guard !didSubmitSuccessfully else { return }

        // 새로 업로드된 이미지가 있으면 삭제 (수정 취소 시)
        guard viewModel.uploadedImageUrl != nil else { return }

        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.deleteNewlyUploadedImageIfNeeded()
                print("✅ 페이지 이탈로 인해 새로 업로드된 이미지 삭제 완료")
            } catch {
                print("❌ 이미지 삭제 실패: \(error)")
            }
        }
    }
}

// Setup

extension ActivityRecordViewController {
    private func setupNavigationBar() {
        title = viewModel.isEditMode ? "내 활동 수정하기" : "내 활동 남기기"

        // X 버튼 (생성/수정 모드 공통)
        let closeButton = UIBarButtonItem(
            image: .Icon.xmark,
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .neutral900
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setupActions() {
        // 취미 칩 선택
        recordView.hobbyChipCollectionView.delegate = self
        recordView.hobbyChipCollectionView.dataSource = self

        // 스티커 선택
        recordView.stickerCollectionView.delegate = self
        recordView.stickerCollectionView.dataSource = self

        // 메모 추천 문장 설정
        setupMemoSuggestions()

        // 사진 CollectionView
        recordView.photoCollectionView.delegate = self
        recordView.photoCollectionView.dataSource = self
        setupPhotoCollectionViewDragDrop()

        // 공개범위 드롭다운 버튼
        recordView.privacyButton.addTarget(
            self,
            action: #selector(privacyButtonTapped),
            for: .touchUpInside
        )

        // 작성완료 버튼
        recordView.submitButton.addTarget(
            self,
            action: #selector(submitButtonTapped),
            for: .touchUpInside
        )

        // 배경 탭하여 드롭다운 닫기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

        // 메모 텍스트뷰
        recordView.memoTextView.delegate = self

        // 활동명 입력 필드
        recordView.activityNameTextField.delegate = self
        recordView.activityNameTextField.addTarget(
            self,
            action: #selector(activityNameTextFieldDidChange),
            for: .editingChanged
        )

        // 이전 활동리스트 버튼
        recordView.previousActivityButton.addTarget(
            self,
            action: #selector(previousActivityButtonTapped),
            for: .touchUpInside
        )
    }

    private func bind() {
        // 취미 칩 목록
        viewModel.$hobbyChips
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recordView.hobbyChipCollectionView.reloadData()
                // wrap 레이아웃 높이 업데이트
                DispatchQueue.main.async {
                    self?.recordView.updateHobbyChipCollectionViewHeight()
                }
            }
            .store(in: &cancellables)

        // 선택된 취미 칩 변경 시 CollectionView 업데이트
        viewModel.$selectedHobbyId
            .dropFirst() // 초기값 무시
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recordView.hobbyChipCollectionView.reloadData()
            }
            .store(in: &cancellables)

        // 작성 완료 버튼 활성화
        viewModel.$isSubmitEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                guard let self = self else { return }
                // 수정 모드에서는 항상 활성화
                let shouldEnable = self.viewModel.isEditMode ? true : isEnabled
                self.recordView.setSubmitButtonEnabled(shouldEnable)
            }
            .store(in: &cancellables)

        // 선택된 이미지들
        viewModel.$selectedImages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recordView.photoCollectionView.reloadData()
            }
            .store(in: &cancellables)

        // 스티커 선택 변경 시 CollectionView 업데이트
        viewModel.$selectedSticker
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recordView.stickerCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func setupForEditMode() {
        if viewModel.isEditMode {
            // 수정 모드: 버튼 텍스트 변경
            recordView.setSubmitButtonTitle("수정완료")

            // 활동명 설정
            recordView.activityNameTextField.text = viewModel.activityName
            recordView.updateActivityNameCount(viewModel.activityName.count)

            // 메모 설정
            recordView.memoTextView.text = viewModel.memo
            recordView.updateMemoCount(viewModel.memo.count)
            recordView.updateMemoPlaceholder(isHidden: !viewModel.memo.isEmpty)

            // 공개범위 UI 설정
            updatePrivacyButton(viewModel.privacy)

            // 단일 취미 칩 표시 (수정 모드)
            if let firstChip = viewModel.displayedHobbyChips.first {
                recordView.showSingleHobbyChip(firstChip.hobbyName, show: true)
            }

            // 기존 이미지 로드
            loadExistingImage()
        }
    }

    private func loadExistingImage() {
        Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.loadOriginalImage()
        }
    }

    private func fetchHobbyChips() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.fetchHobbyChips()
            } catch {
                print("❌ 취미 칩 목록 로드 실패: \(error)")
            }
        }
    }

    private func showPhotoAddBottomSheet() {
        let bottomSheet = PhotoAddBottomSheetViewController()
        bottomSheet.modalPresentationStyle = .overFullScreen
        bottomSheet.modalTransitionStyle = .crossDissolve

        bottomSheet.onOptionSelected = { [weak self] option in
            switch option {
            case .album:
                self?.presentPhotoPicker()
            case .camera:
                self?.checkCameraPermissionAndPresent()
            }
        }

        present(bottomSheet, animated: false)
    }

    /// 활동 추가 팝업 표시
    /// - Note: TODO - API 연결 필요. 현재는 로컬에서만 추가됨
    private func showHobbyAddPopup() {
        let popup = TextInputPopupViewController(
            title: "취미 입력",
            placeholder: "취미를 입력해주세요",
            maxCharacterCount: 20
        )

        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve

        popup.onSubmit = { [weak self] text in
            guard let self = self else { return }
            // 로컬에서 취미 칩 추가 및 선택
            self.viewModel.addLocalHobbyChip(name: text)
        }

        present(popup, animated: true)
    }

    private func checkCameraPermissionAndPresent() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            presentCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.presentCamera()
                    } else {
                        self?.showCameraPermissionDeniedAlert()
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionDeniedAlert()
        @unknown default:
            break
        }
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            ToastView.showError(message: "카메라를 사용할 수 없습니다.")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }

    private func showCameraPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "카메라 접근 권한 필요",
            message: "활동 기록에 사진을 추가하기 위해 카메라 접근 권한이 필요합니다.\n설정에서 권한을 허용해주세요.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })

        present(alert, animated: true)
    }
}

// Actions

extension ActivityRecordViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func backgroundTapped() {
        view.endEditing(true)
        dismissPrivacyDropdown()
    }

    @objc private func privacyButtonTapped() {
        if privacyDropdownView != nil {
            dismissPrivacyDropdown()
        } else {
            showPrivacyDropdown()
        }
    }

    @objc private func activityNameTextFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        viewModel.updateActivityName(text)
        recordView.updateActivityNameCount(text.count)
    }

    @objc private func previousActivityButtonTapped() {
        showPreviousActivityListBottomSheet()
    }

    private func showPreviousActivityListBottomSheet() {
        let bottomSheet = PreviousActivityListBottomSheetViewController()

        bottomSheet.onActivitySelected = { [weak self] activity in
            guard let self = self else { return }
            // 선택한 활동명을 입력 필드에 설정
            self.recordView.activityNameTextField.text = activity.name
            self.viewModel.updateActivityName(activity.name)
            self.recordView.updateActivityNameCount(activity.name.count)
        }

        present(bottomSheet, animated: false)
    }

    @objc private func submitButtonTapped() {
        // 버튼 연타 방지: 제출 중이면 무시
        guard recordView.submitButton.isEnabled else { return }
        recordView.setSubmitButtonEnabled(false)

        Task { [weak self] in
            guard let self = self else { return }
            do {
                // 수정 모드: V1 API 사용, 생성 모드: V2 API 사용
                let activityRecordId: Int
                if self.viewModel.isEditMode {
                    let result = try await self.viewModel.submitActivityRecord()
                    activityRecordId = result.activityRecordId
                    print("✅ 활동 기록 수정 성공: \(result.message)")
                } else {
                    let result = try await self.viewModel.submitActivityRecordV2()
                    activityRecordId = result.activityRecordId
                    print("✅ 활동 기록 작성 성공: \(result.activityContent)")
                }

                await MainActor.run { [weak self] in
                    guard let self = self else { return }

                    // 제출 성공 플래그 설정 (이미지 삭제 방지)
                    self.didSubmitSuccessfully = true

                    // Analytics: 기록 작성 완료 (수정 모드가 아닐 때만)
                    if !self.viewModel.isEditMode {
                        // TODO: entryPoint를 ActivityRecordViewController에 전달하여 정확한 진입점 로그
                        let activityName = self.viewModel.selectedActivity?.content ?? self.viewModel.activityName
                        let hasPhoto = !self.viewModel.selectedImages.isEmpty
                        let hasMemo = !self.viewModel.memo.isEmpty
                        FirebaseAnalyticsService.shared.log(.recordCreated(
                            entryPoint: .gnbRecord, // 임시: 실제 진입점 전달 필요
                            hobbyName: self.hobbyName,
                            activityName: activityName,
                            hasPhoto: hasPhoto,
                            hasMemo: hasMemo
                        ))
                    }

                    // Notify HomeViewController to refresh sticker board
                    AppEventBus.shared.activityRecordCreated.send(self.viewModel.currentHobbyId)

                    // 수정 모드면 기존대로 dismiss, 생성 모드면 상세 화면으로 전환
                    if self.viewModel.isEditMode {
                        self.dismiss(animated: true)
                    } else {
                        // 기록 완료 후 상세 화면으로 전환
                        let nickname = self.coordinator?.getCurrentNickname() ?? "회원"
                        self.coordinator?.showActivityDetailAfterRecord(
                            activityRecordId: activityRecordId,
                            nickname: nickname,
                            from: self
                        )
                    }
                }
            } catch ActivityRecordError.missingRequiredFields {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    print("❌ 필수 항목이 누락되었습니다")
                    self.recordView.setSubmitButtonEnabled(true)
                    self.showErrorAlert(
                        title: "입력 오류",
                        message: "활동과 스티커를 모두 선택해주세요."
                    )
                }
            } catch let appError as AppError {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    let actionType = self.viewModel.isEditMode ? "수정" : "작성"
                    print("❌ 활동 기록 \(actionType) 실패: \(appError)")
                    self.recordView.setSubmitButtonEnabled(true)
                    // Use common error handler
                    self.handleActivityRecordError(appError)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    let actionType = self.viewModel.isEditMode ? "수정" : "작성"
                    print("❌ 활동 기록 \(actionType) 실패: \(error)")
                    self.recordView.setSubmitButtonEnabled(true)
                    self.handleActivityRecordError(.unknown(error))
                }
            }
        }
    }

    private func showErrorAlert(title: String, message: String, action: (() -> Void)? = nil) {
        ToastView.showError(message: message)
        action?()
    }


    private func showPrivacyDropdown() {
        guard privacyDropdownView == nil else { return }

        let dropdown = PrivacyDropdownView(selectedPrivacy: viewModel.privacy)
        dropdown.onPrivacySelected = { [weak self] privacy in
            self?.viewModel.selectPrivacy(privacy)
            self?.updatePrivacyButton(privacy)
            self?.dismissPrivacyDropdown()
        }

        dropdown.show(in: view, below: recordView.privacyButton)
        privacyDropdownView = dropdown
    }

    private func dismissPrivacyDropdown() {
        privacyDropdownView?.dismiss()
        privacyDropdownView = nil
    }

    private func updatePrivacyButton(_ privacy: Privacy) {
        recordView.updatePrivacyButtonTitle(privacy.title)
        recordView.updatePrivacyDescription(privacy)
    }

    private func presentPhotoPicker() {
        // 남은 선택 가능 개수 계산
        let remainingSlots = ActivityRecordViewModel.maxPhotoCount - viewModel.selectedImages.count
        guard remainingSlots > 0 else { return }

        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = remainingSlots
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func deletePhoto(at index: Int) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.removeImage(at: index)
            } catch {
                await MainActor.run { [weak self] in
                    print("❌ 이미지 삭제 실패: \(error)")
                    self?.showErrorAlert(
                        title: "삭제 실패",
                        message: "이미지 삭제에 실패했습니다.\n다시 시도해주세요."
                    )
                }
            }
        }
    }

    private func setupPhotoCollectionViewDragDrop() {
        // 길게 눌러서 드래그
        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPressGesture(_:))
        )
        recordView.photoCollectionView.addGestureRecognizer(longPressGesture)
    }

    @objc private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let collectionView = recordView.photoCollectionView

        switch gesture.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)),
                  indexPath.item < viewModel.selectedImages.count else { return }  // PhotoAddCell 제외
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

}

// UICollectionView

extension ActivityRecordViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recordView.hobbyChipCollectionView {
            // 취미 칩 개수 + 추가 버튼 (수정 모드가 아닐 때만)
            let chipCount = viewModel.displayedHobbyChips.count
            return viewModel.isEditMode ? chipCount : chipCount + 1
        } else if collectionView == recordView.photoCollectionView {
            // 사진 개수 + 추가 버튼 (5장 미만일 때만 추가 버튼 표시)
            let photoCount = viewModel.selectedImages.count
            return photoCount < ActivityRecordViewModel.maxPhotoCount ? photoCount + 1 : photoCount
        } else {
            return viewModel.stickers.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recordView.hobbyChipCollectionView {
            let chipCount = viewModel.displayedHobbyChips.count

            // 마지막 아이템이고 수정 모드가 아닐 때 → 추가 버튼
            if indexPath.item == chipCount && !viewModel.isEditMode {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HobbyAddChipCell", for: indexPath) as? HobbyAddChipCell else {
                    return UICollectionViewCell()
                }
                return cell
            }

            // 취미 칩 셀
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HobbyChipCell", for: indexPath) as? HobbyChipCell else {
                return UICollectionViewCell()
            }

            let hobbyChip = viewModel.displayedHobbyChips[indexPath.item]
            let isSelected = hobbyChip.hobbyId == viewModel.selectedHobbyId
            cell.configure(with: hobbyChip, isSelected: isSelected)

            return cell
        } else if collectionView == recordView.photoCollectionView {
            let photoCount = viewModel.selectedImages.count

            // 마지막 아이템이고 5장 미만일 때 → 추가 버튼
            if indexPath.item == photoCount && photoCount < ActivityRecordViewModel.maxPhotoCount {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAddCell", for: indexPath) as? PhotoAddCell else {
                    return UICollectionViewCell()
                }
                cell.configure(currentCount: photoCount)
                return cell
            }

            // 사진 셀
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {
                return UICollectionViewCell()
            }

            let image = viewModel.selectedImages[indexPath.item]
            cell.configure(with: image)
            cell.onDeleteTapped = { [weak self] in
                self?.deletePhoto(at: indexPath.item)
            }

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as? StickerCell else {
                return UICollectionViewCell()
            }

            let sticker = viewModel.stickers[indexPath.item]
            cell.configure(with: sticker, isSelected: viewModel.selectedSticker == sticker)

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == recordView.hobbyChipCollectionView {
            // 수정 모드에서는 취미 변경 불가
            guard !viewModel.isEditMode else { return }

            let chipCount = viewModel.displayedHobbyChips.count

            // + 버튼 탭 → 활동 추가 팝업 표시
            if indexPath.item == chipCount {
                showHobbyAddPopup()
                return
            }

            let hobbyChip = viewModel.displayedHobbyChips[indexPath.item]
            viewModel.selectHobbyChip(hobbyChip)
        } else if collectionView == recordView.photoCollectionView {
            let photoCount = viewModel.selectedImages.count
            // 추가 버튼 탭
            if indexPath.item == photoCount && photoCount < ActivityRecordViewModel.maxPhotoCount {
                showPhotoAddBottomSheet()
            }
        } else {
            let sticker = viewModel.stickers[indexPath.item]
            viewModel.selectSticker(sticker)
            collectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == recordView.stickerCollectionView {
            return CGSize(width: 64, height: 64)
        } else if collectionView == recordView.photoCollectionView {
            return CGSize(width: 56, height: 56)  // 52 + 삭제 버튼 여백
        } else if collectionView == recordView.hobbyChipCollectionView {
            let chipCount = viewModel.displayedHobbyChips.count

            // + 버튼 크기
            if indexPath.item == chipCount && !viewModel.isEditMode {
                return HobbyAddChipCell.cellSize
            }

            // Hobby chip: Cell이 텍스트 길이에 따라 크기 계산
            let hobbyChip = viewModel.displayedHobbyChips[indexPath.item]
            return HobbyChipCell.size(for: hobbyChip)
        }

        return CGSize.zero
    }

    // MARK: - Photo CollectionView Reordering

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard collectionView == recordView.photoCollectionView else { return false }
        // PhotoAddCell은 이동 불가
        return indexPath.item < viewModel.selectedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard collectionView == recordView.photoCollectionView else { return }
        // PhotoAddCell 위치로는 이동 불가
        guard destinationIndexPath.item < viewModel.selectedImages.count else { return }
        viewModel.moveImage(from: sourceIndexPath.item, to: destinationIndexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        guard collectionView == recordView.photoCollectionView else { return proposedIndexPath }
        // PhotoAddCell 위치로 이동 방지
        let maxIndex = viewModel.selectedImages.count - 1
        if proposedIndexPath.item > maxIndex {
            return IndexPath(item: maxIndex, section: 0)
        }
        return proposedIndexPath
    }
}

// PHPickerViewControllerDelegate & UIImagePickerControllerDelegate

extension ActivityRecordViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard !results.isEmpty else { return }

        // 다중 이미지 로드
        Task { [weak self] in
            guard let self = self else { return }

            var loadedImages: [UIImage] = []

            for result in results {
                if let image = await self.loadImage(from: result) {
                    loadedImages.append(image)
                }
            }

            guard !loadedImages.isEmpty else { return }

            do {
                try await self.viewModel.addImages(loadedImages)
                print("✅ \(loadedImages.count)개 이미지 추가 성공")
            } catch {
                print("❌ 이미지 추가 실패: \(error)")
            }
        }
    }

    private func loadImage(from result: PHPickerResult) async -> UIImage? {
        await withCheckedContinuation { continuation in
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let error = error {
                    print("❌ 이미지 로드 실패: \(error)")
                    continuation.resume(returning: nil)
                    return
                }

                guard let image = object as? UIImage else {
                    print("❌ 이미지 변환 실패")
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: image)
            }
        }
    }

    // UIImagePickerControllerDelegate (카메라)
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            print("❌ 카메라 이미지 가져오기 실패")
            return
        }

        // 이미지 추가
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.addImages([image])
                print("✅ 카메라 이미지 추가 성공")
            } catch {
                print("❌ 카메라 이미지 추가 실패: \(error)")
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// Memo Suggestions

extension ActivityRecordViewController {
    private func setupMemoSuggestions() {
        // TODO: 서버 API 연동 예정 - 현재 임시 문자열 배열 사용
        let suggestions = [
            "오늘도 한 챕터",
            "읽었다!",
            "집중 완료",
            "오늘의 문장 발견"
        ]
        recordView.memoSuggestionView.updateSuggestions(suggestions)

        // 추천 문장 선택 콜백 설정
        recordView.memoSuggestionView.onSuggestionSelected = { [weak self] suggestion in
            self?.insertSuggestionAtCursor(suggestion)
        }
    }

    /// 커서 위치에 추천 문장 삽입
    /// - Parameter suggestion: 삽입할 추천 문장
    private func insertSuggestionAtCursor(_ suggestion: String) {
        let textView = recordView.memoTextView
        let currentText = textView.text ?? ""
        let maxLength = 100

        // 현재 커서 위치 가져오기
        guard let selectedRange = textView.selectedTextRange else {
            // 커서가 없으면 맨 끝에 삽입
            appendSuggestionToEnd(suggestion, currentText: currentText, maxLength: maxLength)
            return
        }

        let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)

        // 삽입할 텍스트 준비 (앞에 텍스트가 있고, 공백이 아니면 공백 추가)
        var textToInsert = suggestion
        if cursorPosition > 0 {
            let index = currentText.index(currentText.startIndex, offsetBy: cursorPosition - 1)
            let charBefore = currentText[index]
            if !charBefore.isWhitespace {
                textToInsert = " " + suggestion
            }
        }

        // 최대 글자수 제한 처리
        let availableLength = maxLength - currentText.count
        if availableLength <= 0 {
            return // 더 이상 입력 불가
        }

        if textToInsert.count > availableLength {
            textToInsert = String(textToInsert.prefix(availableLength))
        }

        // 텍스트 삽입
        textView.replace(selectedRange, withText: textToInsert)

        // ViewModel 및 UI 업데이트
        let newText = textView.text ?? ""
        viewModel.updateMemo(newText)
        recordView.updateMemoCount(newText.count)
        recordView.updateMemoPlaceholder(isHidden: !newText.isEmpty)
    }

    private func appendSuggestionToEnd(_ suggestion: String, currentText: String, maxLength: Int) {
        let textView = recordView.memoTextView

        // 삽입할 텍스트 준비 (앞에 텍스트가 있고, 공백이 아니면 공백 추가)
        var textToInsert = suggestion
        if !currentText.isEmpty {
            let lastChar = currentText.last!
            if !lastChar.isWhitespace {
                textToInsert = " " + suggestion
            }
        }

        // 최대 글자수 제한 처리
        let availableLength = maxLength - currentText.count
        if availableLength <= 0 {
            return
        }

        if textToInsert.count > availableLength {
            textToInsert = String(textToInsert.prefix(availableLength))
        }

        // 텍스트 추가
        textView.text = currentText + textToInsert

        // ViewModel 및 UI 업데이트
        let newText = textView.text ?? ""
        viewModel.updateMemo(newText)
        recordView.updateMemoCount(newText.count)
        recordView.updateMemoPlaceholder(isHidden: !newText.isEmpty)
    }
}

// UITextViewDelegate

extension ActivityRecordViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        // 100자 제한: 초과하면 입력 차단
        return updatedText.count <= 100
    }

    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""

        viewModel.updateMemo(text)
        recordView.updateMemoCount(text.count)

        // 플레이스홀더 표시/숨김
        recordView.updateMemoPlaceholder(isHidden: !text.isEmpty)
    }
}

// UITextFieldDelegate

extension ActivityRecordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == recordView.activityNameTextField else { return true }

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // 20자 제한
        return updatedText.count <= 20
    }
}

// UIGestureRecognizerDelegate

extension ActivityRecordViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchedView = touch.view else { return true }
        let excludedViews = [
            recordView.privacyButton,
            privacyDropdownView
        ].compactMap { $0 }

        guard !excludedViews.contains(where: { touchedView.isDescendant(of: $0) }) else {
            return false
        }

        return true
    }
}

//#Preview {
//    let nav = UINavigationController()
//    let vc = ActivityRecordViewController()
//    nav.setViewControllers([vc], animated: false)
//    return nav
//}
