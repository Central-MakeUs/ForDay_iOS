//
//  ActivityDetailViewController.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class ActivityDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties

    private var detailView: ActivityDetailView {
        return view as! ActivityDetailView
    }

    private let viewModel: ActivityDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private var dropdownView: ActivityDetailDropdownView?

    weak var coordinator: MainTabBarCoordinator?

    // 기록 완료 후 모드 관련
    private let displayMode: ActivityDetailView.DisplayMode
    private let nickname: String?
    private var successOverlayView: ActivityRecordSuccessOverlayView?

    // MARK: - Initialization

    init(
        viewModel: ActivityDetailViewModel,
        displayMode: ActivityDetailView.DisplayMode = .normal,
        nickname: String? = nil
    ) {
        self.viewModel = viewModel
        self.displayMode = displayMode
        self.nickname = nickname
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = ActivityDetailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavigationBar()
        setupGestures()
        setupDisplayMode()
        bind()
        loadData()
    }

    private func setupDisplayMode() {
        detailView.setDisplayMode(displayMode)

        if displayMode == .afterRecord {
            // 홈으로 가기 버튼 액션 연결
            detailView.goHomeButton.addTarget(self, action: #selector(goHomeButtonTapped), for: .touchUpInside)
        }
    }

    @objc private func goHomeButtonTapped() {
        // 모든 presented VC dismiss 후 홈으로 이동
        coordinator?.switchToHomeTab()
        dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 기본 내비게이션 숨기기 (커스텀 내비게이션 사용)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 기록 완료 후 모드일 때 로띠 오버레이 표시
        if displayMode == .afterRecord, successOverlayView == nil {
            showSuccessOverlay()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 다른 화면으로 이동 시 기본 내비게이션 복원
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func showSuccessOverlay() {
        let overlay = ActivityRecordSuccessOverlayView()
        overlay.configure(nickname: nickname ?? "회원")
        overlay.show(in: view)
        successOverlayView = overlay
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

// MARK: - Setup

extension ActivityDetailViewController {
    private func setupCustomNavigationBar() {
        // 커스텀 내비게이션 버튼 액션 연결
        detailView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        detailView.moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        detailView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func saveButtonTapped() {
        guard let detail = viewModel.activityDetail else { return }

        print("💾 Save button tapped - navigating to template selector")

        let templateViewModel = ImageTemplateSelectorViewModel(activityDetail: detail)
        let templateVC = ImageTemplateSelectorViewController(viewModel: templateViewModel)
        navigationController?.pushViewController(templateVC, animated: true)
    }

    private func setupGestures() {
        // Background tap to dismiss dropdown
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func bind() {
        // Activity detail
        viewModel.$activityDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                guard let detail = detail else { return }
                self?.detailView.configure(with: detail)
                self?.setupUserInfoTap(with: detail)
            }
            .store(in: &cancellables)

        // Loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                if isLoading {
                    print("🔄 Loading activity detail...")
                } else {
                    print("✅ Activity detail loaded")
                }
            }
            .store(in: &cancellables)

        // Error handling
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                // Use common error handler with retry support
                self?.handleActivityDetailError(error) {
                    self?.loadData()
                }
            }
            .store(in: &cancellables)

        // Reaction button single tapped (show users)
        detailView.reactionButtonsView.reactionSingleTapped
            .sink { [weak self] reactionType in
                self?.handleReactionSingleTapped(reactionType)
            }
            .store(in: &cancellables)

        // Reaction button double tapped (toggle reaction)
        detailView.reactionButtonsView.reactionDoubleTapped
            .sink { [weak self] reactionType in
                self?.handleReactionDoubleTapped(reactionType)
            }
            .store(in: &cancellables)

        // Reaction users
        viewModel.$reactionUsers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                guard let self = self else { return }

                if users.isEmpty {
                    self.detailView.reactionUsersScrollView.isHidden = true
                    self.detailView.reactionUsersScrollView.clear()

                    // Collapse height when hidden
                    self.detailView.reactionUsersScrollView.snp.updateConstraints {
                        $0.height.equalTo(0)
                    }
                } else {
                    self.detailView.reactionUsersScrollView.isHidden = false
                    self.detailView.reactionUsersScrollView.configure(with: users)

                    // Expand height when visible
                    self.detailView.reactionUsersScrollView.snp.updateConstraints {
                        $0.height.equalTo(60)
                    }
                }

                // Animate layout change
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)

        // Bookmark button tapped
        detailView.reactionButtonsView.bookmarkTapped
            .sink { [weak self] in
                self?.handleBookmarkTapped()
            }
            .store(in: &cancellables)
    }

    private func loadData() {
        Task {
            await viewModel.fetchDetail()
        }
    }

    private func setupUserInfoTap(with detail: ActivityDetail) {
        guard let userInfo = detail.userInfo, !detail.recordOwner else { return }

        detailView.userInfoView.onTap = { [weak self] in
            self?.coordinator?.showUserProfile(userId: userInfo.userId)
        }
    }
}

// MARK: - Actions

extension ActivityDetailViewController {
    @objc private func moreButtonTapped() {
        print("⋯ More button tapped")

        // Dismiss dropdown if already showing
        if dropdownView != nil {
            dismissDropdown()
            return
        }

        // Show custom dropdown
        showDropdown()
    }

    @objc private func backgroundTapped() {
        dismissDropdown()
    }

    private func showDropdown() {
        guard dropdownView == nil else { return }

        // 소유자 여부와 이미지 유무에 따라 드롭다운 옵션 구성
        let isOwner = viewModel.activityDetail?.recordOwner ?? false
        let hasImage = detailView.hasImage
        let dropdown = ActivityDetailDropdownView(isOwner: isOwner, showCoverImageOption: hasImage)
        dropdown.onOptionSelected = { [weak self] option in
            self?.handleDropdownOption(option)
            self?.dismissDropdown()
        }

        // 커스텀 내비게이션의 more 버튼 아래에 표시
        dropdown.show(in: view, below: detailView.moreButton)
        dropdownView = dropdown
    }

    private func dismissDropdown() {
        dropdownView?.dismiss()
        dropdownView = nil
    }

    private func handleDropdownOption(_ option: ActivityDetailDropdownOption) {
        switch option {
        case .setCoverImage:
            setAsProfileImage()
        case .edit:
            editActivity()
        case .delete:
            showDeleteConfirmation()
        case .report:
            showReportScreen()
        }
    }

    private func setAsProfileImage() {
        guard let detail = viewModel.activityDetail else { return }

        print("📸 대표사진 설정: \(detail.imageUrl)")

        Task {
            do {
                try await viewModel.setCoverImage()
                await MainActor.run {
                    print("✅ 대표사진 설정 성공")
                    showSuccessAlert(
                        title: "완료",
                        message: "대표사진이 설정되었습니다."
                    )
                }
            } catch let appError as AppError {
                await MainActor.run {
                    print("❌ 대표사진 설정 실패: \(appError)")
                    handleAppError(appError)
                }
            } catch {
                await MainActor.run {
                    print("❌ 대표사진 설정 실패: \(error)")
                    handleAppError(.unknown(error))
                }
            }
        }
    }

    private func editActivity() {
        guard let detail = viewModel.activityDetail else { return }

        print("✏️ 수정하기")

        // ActivityRecordViewController를 수정 모드로 열기
        // hobbyName은 수정 모드에서는 크게 필요하지 않으므로 기본값 사용
        let recordVC = ActivityRecordViewController(hobbyId: viewModel.hobbyId, hobbyName: "취미", activityDetail: detail)
        let nav = UINavigationController(rootViewController: recordVC)
        nav.modalPresentationStyle = .fullScreen

        present(nav, animated: true)
    }

    private func showDeleteConfirmation() {
        print("🗑️ 삭제 확인 팝업 표시")

        let popupVC = CommonPopupViewController(
            title: "활동 기록 삭제",
            message: "정말 이 활동 기록을\n삭제하시겠어요?",
            primaryButtonTitle: "삭제",
            secondaryButtonTitle: "취소"
        )
        popupVC.onPrimaryAction = { [weak self] in
            self?.deleteActivity()
        }

        present(popupVC, animated: true)
    }

    private func deleteActivity() {
        print("🗑️ 활동 기록 삭제")

        Task {
            do {
                try await viewModel.deleteRecord()
                await MainActor.run {
                    print("✅ 활동 기록 삭제 성공")

                    // Notify observers that a record was deleted
                    if let detail = viewModel.activityDetail {
                        AppEventBus.shared.activityRecordCreated.send(detail.hobbyId)
                    }

                    // Navigate back
                    navigationController?.popViewController(animated: true)
                }
            } catch let appError as AppError {
                await MainActor.run {
                    print("❌ 활동 기록 삭제 실패: \(appError)")
                    handleAppError(appError)
                }
            } catch {
                await MainActor.run {
                    print("❌ 활동 기록 삭제 실패: \(error)")
                    handleAppError(.unknown(error))
                }
            }
        }
    }

    private func showSuccessAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func handleReactionSingleTapped(_ reactionType: ReactionType) {
        print("👆 \(reactionType.displayName) 반응 버튼 단일 탭 - 유저 목록 표시")

        Task {
            await viewModel.fetchReactionUsers(for: reactionType)
        }
    }

    private func handleReactionDoubleTapped(_ reactionType: ReactionType) {
        print("👆👆 \(reactionType.displayName) 반응 버튼 더블 탭 - 반응 추가/삭제")

        Task {
            await viewModel.toggleReaction(reactionType)
        }
    }

    private func handleBookmarkTapped() {
        print("🔖 북마크 버튼 탭 - 스크랩 추가/삭제")

        Task {
            await viewModel.toggleScrap()
        }
    }

    private func showReportScreen() {
        guard let detail = viewModel.activityDetail,
              let userInfo = detail.userInfo else { return }

        print("🚨 신고하기")

        let reportVC = ReportViewController(
            recordId: detail.activityRecordId,
            authorUserId: userInfo.userId,
            authorNickname: userInfo.nickname
        )
        reportVC.modalPresentationStyle = .fullScreen
        reportVC.onReportCompleted = { [weak self] _ in
            // 신고 완료 후 Stories 탭으로 이동
            self?.coordinator?.switchToStoriesTab()
            self?.navigationController?.popToRootViewController(animated: false)
        }

        present(reportVC, animated: true)
    }
}

#if DEBUG
#Preview("ActivityDetailViewController - Basic") {
    let viewModel = ActivityDetailViewModel(activityRecordId: 1)
    let vc = ActivityDetailViewController(viewModel: viewModel)

    // Manually configure view with mock data (bypass network call)
    vc.loadViewIfNeeded()
    (vc.view as? ActivityDetailView)?.configure(with: .preview)

    let nav = UINavigationController(rootViewController: vc)
    return nav
}

#Preview("ActivityDetailViewController - Scraped") {
    let viewModel = ActivityDetailViewModel(activityRecordId: 2)
    let vc = ActivityDetailViewController(viewModel: viewModel)

    vc.loadViewIfNeeded()
    (vc.view as? ActivityDetailView)?.configure(with: .previewScraped)

    let nav = UINavigationController(rootViewController: vc)
    return nav
}

#Preview("ActivityDetailViewController - All Reactions") {
    let viewModel = ActivityDetailViewModel(activityRecordId: 3)
    let vc = ActivityDetailViewController(viewModel: viewModel)

    vc.loadViewIfNeeded()
    (vc.view as? ActivityDetailView)?.configure(with: .previewWithAllReactions)

    let nav = UINavigationController(rootViewController: vc)
    return nav
}
#endif
