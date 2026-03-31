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

final class ActivityDetailViewController: UIViewController {

    // MARK: - Properties

    private var detailView: ActivityDetailView {
        return view as! ActivityDetailView
    }

    let viewModel: ActivityDetailViewModel  // PageViewController에서 접근 필요
    private var cancellables = Set<AnyCancellable>()
    private var dropdownView: ActivityDetailDropdownView?

    weak var coordinator: MainTabBarCoordinator?

    // 기록 완료 후 모드 관련
    private let displayMode: ActivityDetailView.DisplayMode
    private let nickname: String?
    private var successOverlayView: ActivityRecordSuccessOverlayView?

    // 페이징 모드 여부 (부모 PageVC가 있으면 true)
    private let isPagingMode: Bool

    // 수정 후 재조회 플래그
    private var needsRefreshAfterEdit = false

    // MARK: - Paging Control Properties

    var canPageToPrevious: Bool {
        return detailView.scrollView.contentOffset.y <= 0
    }

    var canPageToNext: Bool {
        let scrollView = detailView.scrollView
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height

        // 컨텐츠가 화면보다 작으면 항상 페이징 가능, 아니면 바닥에 닿았을 때 페이징 가능
        if contentHeight <= frameHeight {
            return true
        }
        return offsetY >= (contentHeight - frameHeight - 1)
    }

    // MARK: - Initialization

    init(
        viewModel: ActivityDetailViewModel,
        displayMode: ActivityDetailView.DisplayMode = .normal,
        nickname: String? = nil,
        isPagingMode: Bool = false
    ) {
        self.viewModel = viewModel
        self.displayMode = displayMode
        self.nickname = nickname
        self.isPagingMode = isPagingMode
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
        setupGestures()
        setupDisplayMode()
        setupRefreshControl()
        bind()
        loadData()
    }

    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        detailView.setRefreshControl(refreshControl)
    }

    @objc private func handleRefresh() {
        loadData()
    }

    private func setupDisplayMode() {
        detailView.setDisplayMode(displayMode)
        detailView.setPagingMode(isPagingMode)

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
        // 기본 내비게이션 숨기기 (부모인 PageVC에서 커스텀 내비게이션 관리)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        // 수정 후 돌아왔을 때 데이터 재조회
        if needsRefreshAfterEdit {
            needsRefreshAfterEdit = false
            loadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 기록 완료 후 모드일 때 로띠 오버레이 표시
        if displayMode == .afterRecord, successOverlayView == nil {
            showSuccessOverlay()
        }
    }


    private func showSuccessOverlay() {
        let overlay = ActivityRecordSuccessOverlayView()
        overlay.configure(nickname: nickname ?? "회원")
        overlay.show(in: view)
        successOverlayView = overlay
    }
}

// MARK: - Setup

extension ActivityDetailViewController {
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
            .sink { [weak self] isLoading in
                if isLoading {
                    print("🔄 Loading activity detail...")
                } else {
                    print("✅ Activity detail loaded")
                    self?.detailView.endRefreshing()
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

        // MARK: - Reaction Bindings (단일 보기 모드 전용)
        if !isPagingMode {
            bindReactionViews()
        }
    }

    private func bindReactionViews() {
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

        // Bookmark button tapped
        detailView.reactionButtonsView.bookmarkTapped
            .sink { [weak self] in
                self?.handleBookmarkTapped()
            }
            .store(in: &cancellables)

        // Reaction users scroll view visibility
        viewModel.$reactionUsers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                guard let self = self else { return }

                if users.isEmpty {
                    self.detailView.reactionUsersScrollView.isHidden = true
                    self.detailView.reactionUsersScrollView.clear()
                    self.detailView.reactionUsersScrollView.snp.updateConstraints { $0.height.equalTo(0) }
                } else {
                    self.detailView.reactionUsersScrollView.isHidden = false
                    self.detailView.reactionUsersScrollView.configure(with: users)
                    self.detailView.reactionUsersScrollView.snp.updateConstraints { $0.height.equalTo(60) }
                }

                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
    }

    private func loadData() {
        Task { [weak self] in
            await self?.viewModel.fetchDetail()
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
    private func handleReactionSingleTapped(_ reactionType: ReactionType) {
        Task { [weak self] in
            await self?.viewModel.fetchReactionUsers(for: reactionType)
        }
    }

    private func handleReactionDoubleTapped(_ reactionType: ReactionType) {
        Task { [weak self] in
            await self?.viewModel.toggleReaction(reactionType)
        }
    }

    private func handleBookmarkTapped() {
        Task { [weak self] in
            await self?.viewModel.toggleScrap()
        }
    }
}

// MARK: - Public Actions (Called from Parent PageVC)

extension ActivityDetailViewController {
    func handleMoreButtonTapped(sourceView: UIView) {
        print("⋯ More button tapped")

        // Dismiss dropdown if already showing
        if dropdownView != nil {
            dismissDropdown()
            return
        }

        // Show custom dropdown
        showDropdown(sourceView: sourceView)
    }

    func handleSaveButtonTapped() {
        guard let detail = viewModel.activityDetail else { return }

        print("💾 Save button tapped - navigating to template selector")

        let templateViewModel = ImageTemplateSelectorViewModel(activityDetail: detail)
        let templateVC = ImageTemplateSelectorViewController(viewModel: templateViewModel)
        navigationController?.pushViewController(templateVC, animated: true)
    }

    @objc private func backgroundTapped() {
        dismissDropdown()
    }

    private func showDropdown(sourceView: UIView) {
        guard dropdownView == nil else { return }

        // 소유자 여부와 이미지 유무에 따라 드롭다운 옵션 구성
        let isOwner = viewModel.activityDetail?.recordOwner ?? false
        let hasImage = detailView.hasImage
        let dropdown = ActivityDetailDropdownView(isOwner: isOwner, showCoverImageOption: hasImage)
        dropdown.onOptionSelected = { [weak self] option in
            self?.handleDropdownOption(option)
            self?.dismissDropdown()
        }

        // 부모의 more 버튼 아래에 표시 (PageVC에서 전달받은 sourceView 사용)
        dropdown.show(in: view, below: sourceView)
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

        print("📸 대표사진 설정 시작")

        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.setCoverImage()
                await MainActor.run { [weak self] in
                    print("✅ 대표사진 설정 성공")
                    self?.showSuccessAlert(
                        title: "완료",
                        message: "대표사진이 설정되었습니다."
                    )
                }
            } catch let appError as AppError {
                await MainActor.run { [weak self] in
                    print("❌ 대표사진 설정 실패: \(appError)")
                    self?.handleAppError(appError)
                }
            } catch {
                await MainActor.run { [weak self] in
                    print("❌ 대표사진 설정 실패: \(error)")
                    self?.handleAppError(.unknown(error))
                }
            }
        }
    }

    private func editActivity() {
        guard let detail = viewModel.activityDetail else { return }

        print("✏️ 수정하기")

        let recordVC = ActivityRecordViewController(hobbyId: viewModel.hobbyId, hobbyName: "취미", activityDetail: detail)
        let nav = BaseNavigationController(rootViewController: recordVC)
        nav.modalPresentationStyle = .fullScreen

        present(nav, animated: true) { [weak self] in
            self?.needsRefreshAfterEdit = true
        }
    }

    private func showDeleteConfirmation() {
        print("🗑️ 삭제 확인 팝업 표시")

        let popupVC = CommonPopupViewController(
            title: "활동 기록 삭제",
            message: "삭제 시 복구는 안돼요!",
            primaryButtonTitle: "삭제하기",
            secondaryButtonTitle: "닫기"
        )
        popupVC.onPrimaryAction = { [weak self] in
            self?.deleteActivity()
        }

        present(popupVC, animated: true)
    }

    private func deleteActivity() {
        print("🗑️ 활동 기록 삭제")

        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.deleteRecord()
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    print("✅ 활동 기록 삭제 성공")

                    if let detail = self.viewModel.activityDetail {
                        AppEventBus.shared.activityRecordCreated.send(detail.hobbyId)
                    }

                    self.navigationController?.popViewController(animated: true)
                }
            } catch let appError as AppError {
                await MainActor.run { [weak self] in
                    print("❌ 활동 기록 삭제 실패: \(appError)")
                    self?.handleAppError(appError)
                }
            } catch {
                await MainActor.run { [weak self] in
                    print("❌ 활동 기록 삭제 실패: \(error)")
                    self?.handleAppError(.unknown(error))
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

    private func showReportScreen() {
        guard let detail = viewModel.activityDetail,
              let userInfo = detail.userInfo else { return }

        print("🚨 신고하기")

        let reportVC = ReportViewController(
            recordId: detail.activityRecordId,
            authorUserId: userInfo.userId,
            authorNickname: userInfo.nickname
        )
        reportVC.onReportCompleted = { [weak self] _ in
            self?.coordinator?.switchToStoriesTab()
            self?.navigationController?.popToRootViewController(animated: false)
        }

        navigationController?.pushViewController(reportVC, animated: true)
    }
}
