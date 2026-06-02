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
    private var activityDropdownView: ActivityDropdownView?
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
        fetchActivities()
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

        // 활동 드롭다운 버튼
        recordView.activityDropdownButton.addTarget(
            self,
            action: #selector(activityDropdownButtonTapped),
            for: .touchUpInside
        )

        // 취미활동 추가하기 버튼 (활동이 없을 때)
        recordView.addActivityButton.addTarget(
            self,
            action: #selector(addActivityButtonTapped),
            for: .touchUpInside
        )

        // 사진 추가 버튼
        recordView.photoAddButton.addTarget(
            self,
            action: #selector(photoAddButtonTapped),
            for: .touchUpInside
        )

        // 사진 삭제
        recordView.photoDeleteButton.addTarget(
            self,
            action: #selector(photoDeleteButtonTapped),
            for: .touchUpInside
        )

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
    }

    private func bind() {
        // 취미 칩 목록
        viewModel.$hobbyChips
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recordView.hobbyChipCollectionView.reloadData()
            }
            .store(in: &cancellables)

        // 선택된 취미 칩 변경 시 활동 목록 새로고침
        viewModel.$selectedHobbyId
            .dropFirst() // 초기값 무시
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recordView.hobbyChipCollectionView.reloadData()
                self?.fetchActivities()
            }
            .store(in: &cancellables)

        // 활동 선택
        viewModel.$selectedActivity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activity in
                self?.recordView.updateActivityTitle(activity?.content)
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

        // 선택된 이미지
        viewModel.$selectedImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.recordView.updatePhotoImage(image)
            }
            .store(in: &cancellables)

        // 활동 목록 변경 시 UI 업데이트
        viewModel.$activities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activities in
                self?.recordView.showAddActivityButton(activities.isEmpty)
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

    private func fetchActivities() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.fetchActivityList()
            } catch {
                print("❌ 활동 목록 로드 실패: \(error)")
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

    @objc private func activityDropdownButtonTapped() {
        if activityDropdownView != nil {
            dismissActivityDropdown()
        } else {
            showActivityDropdown()
        }
    }

    @objc private func addActivityButtonTapped() {
        // 현재 화면 dismiss 후 HobbyActivityInputViewController 표시
        let hobbyId = viewModel.currentHobbyId
        let currentHobbyName = hobbyName
        let presentingVC = presentingViewController

        dismiss(animated: true) {
            guard let presenter = presentingVC else { return }

            let inputVC = HobbyActivityInputViewController(hobbyId: hobbyId, hobbyName: currentHobbyName)
            inputVC.onActivityCreated = { [weak inputVC] in
                // 활동 생성 완료 시 dismiss
                inputVC?.dismiss(animated: true)
            }

            let nav = BaseNavigationController(rootViewController: inputVC)
            nav.modalPresentationStyle = .fullScreen
            presenter.present(nav, animated: true)
        }
    }

    @objc private func backgroundTapped() {
        view.endEditing(true)
        dismissActivityDropdown()
        dismissPrivacyDropdown()
    }

    @objc private func photoDeleteButtonTapped() {
        deletePhoto()
    }

    @objc private func photoAddButtonTapped() {
        // 이미지가 이미 있으면 아무 동작 안 함
        guard viewModel.selectedImage == nil else { return }
        showPhotoAddBottomSheet()
    }

    @objc private func privacyButtonTapped() {
        if privacyDropdownView != nil {
            dismissPrivacyDropdown()
        } else {
            showPrivacyDropdown()
        }
    }

    @objc private func submitButtonTapped() {
        // 버튼 연타 방지: 제출 중이면 무시
        guard recordView.submitButton.isEnabled else { return }
        recordView.setSubmitButtonEnabled(false)

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let result = try await self.viewModel.submitActivityRecord()
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    let actionType = self.viewModel.isEditMode ? "수정" : "작성"
                    print("✅ 활동 기록 \(actionType) 성공: \(result.message)")

                    // 제출 성공 플래그 설정 (이미지 삭제 방지)
                    self.didSubmitSuccessfully = true

                    // Analytics: 기록 작성 완료 (수정 모드가 아닐 때만)
                    if !self.viewModel.isEditMode {
                        // TODO: entryPoint를 ActivityRecordViewController에 전달하여 정확한 진입점 로그
                        let activityName = self.viewModel.selectedActivity?.content ?? ""
                        let hasPhoto = self.viewModel.selectedImage != nil
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
                            activityRecordId: result.activityRecordId,
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


    private func showActivityDropdown() {
        guard activityDropdownView == nil else { return }

        let dropdown = ActivityDropdownView(activities: viewModel.activities)
        dropdown.onActivitySelected = { [weak self] activity in
            self?.viewModel.selectActivity(activity)
            self?.dismissActivityDropdown()
        }

        dropdown.show(in: view, below: recordView.activityDropdownButton)
        activityDropdownView = dropdown
    }

    private func dismissActivityDropdown() {
        activityDropdownView?.dismiss()
        activityDropdownView = nil
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
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func deletePhoto() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.removeImageFromUI()
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

}

// UICollectionView

extension ActivityRecordViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recordView.hobbyChipCollectionView {
            return viewModel.displayedHobbyChips.count
        } else {
            return viewModel.stickers.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recordView.hobbyChipCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HobbyChipCell", for: indexPath) as? HobbyChipCell else {
                return UICollectionViewCell()
            }

            let hobbyChip = viewModel.displayedHobbyChips[indexPath.item]
            let isSelected = hobbyChip.hobbyId == viewModel.selectedHobbyId
            cell.configure(with: hobbyChip, isSelected: isSelected)

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

            let hobbyChip = viewModel.displayedHobbyChips[indexPath.item]
            viewModel.selectHobbyChip(hobbyChip)
        } else {
            let sticker = viewModel.stickers[indexPath.item]
            viewModel.selectSticker(sticker)
            collectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == recordView.stickerCollectionView {
            return CGSize(width: 64, height: 64)
        }

        // Hobby chip: Cell이 텍스트 길이에 따라 크기 계산
        let hobbyChip = viewModel.displayedHobbyChips[indexPath.item]
        return HobbyChipCell.size(for: hobbyChip)
    }
}

// PHPickerViewControllerDelegate & UIImagePickerControllerDelegate

extension ActivityRecordViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ 이미지 로드 실패: \(error)")
                return
            }

            guard let image = object as? UIImage else {
                print("❌ 이미지 변환 실패")
                return
            }

            // 이미지 업로드
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    try await self.viewModel.uploadImage(image)
                    print("✅ 이미지 업로드 성공")
                } catch {
                    print("❌ 이미지 업로드 실패: \(error)")
                }
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

        // 이미지 업로드
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.uploadImage(image)
                print("✅ 카메라 이미지 업로드 성공")
            } catch {
                print("❌ 카메라 이미지 업로드 실패: \(error)")
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// UITextViewDelegate

extension ActivityRecordViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""

        // 100자 제한
        if text.count > 100 {
            let limitedText = String(text.prefix(100))
            textView.text = limitedText
            viewModel.updateMemo(limitedText)
            recordView.updateMemoCount(100)
        } else {
            viewModel.updateMemo(text)
            recordView.updateMemoCount(text.count)
        }

        // 플레이스홀더 표시/숨김
        recordView.updateMemoPlaceholder(isHidden: !text.isEmpty)
    }
}

// UIGestureRecognizerDelegate

extension ActivityRecordViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchedView = touch.view else { return true }
        let excludedViews = [
            recordView.privacyButton,
            recordView.activityDropdownButton,
            privacyDropdownView,
            activityDropdownView
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
