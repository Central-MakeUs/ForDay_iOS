//
//  HomeViewController.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import UIKit
import Combine
import SnapKit

class HomeViewController: UIViewController {
    
    // Properties

    private let homeView = HomeView()
    let viewModel = HomeViewModel()
    private let stickerBoardViewModel = StickerBoardViewModel()
    private var cancellables = Set<AnyCancellable>()

    // TODO: HomeInfo API에 nickname 필드 추가되면 getCurrentNickname() 수정 필요
    // 현재는 greetingMessage에서 파싱하여 사용 중
    
    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // Activity Dropdown
    private var dropdownBackgroundView: UIView?
    private var activityDropdownView: ActivityDropdownView?

    // Flag to update activity preview to the first item after activity creation
    private var shouldSelectFirstActivity = false

    // Settings Dropdown
    private var settingsDropdownBackgroundView: UIView?
    private var settingsDropdownView: DropdownMenuView<HomeSettingsMenuItem>?
    
    // Lifecycle
    
    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupRefreshControl()
        setupActions()
        setupStickerBoardCallbacks()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)

        // 활동 생성 후 돌아왔을 때 드롭다운 첫번째 항목 선택
        let needsFirstActivitySelection = shouldSelectFirstActivity
        if shouldSelectFirstActivity {
            shouldSelectFirstActivity = false
        }

        // 이미 선택된 취미가 있으면 유지, 없으면 서버가 결정
        loadHomeData(hobbyId: viewModel.currentHobbyId, selectFirstActivity: needsFirstActivitySelection)
    }

    private func loadHomeData(hobbyId: Int? = nil, selectFirstActivity: Bool = false) {
        Task { [weak self] in
            guard let self = self else { return }
            // hobbyId가 전달되면 해당 취미로, 아니면 서버가 결정하도록 함
            // (취미설정에서 보관/꺼내기 후 돌아왔을 때 정확한 상태 반영)
            await self.viewModel.fetchHomeInfo(hobbyId: hobbyId)
            // fetchHomeInfo 완료 후 업데이트된 currentHobbyId 사용
            await self.stickerBoardViewModel.loadInitialStickerBoard(hobbyId: self.viewModel.currentHobbyId)

            // 활동 생성 후 돌아왔을 때 드롭다운 첫번째 항목 선택
            if selectFirstActivity {
                await self.selectFirstActivityAsync()
            }
        }
    }
}

// Setup

extension HomeViewController {
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupRefreshControl() {
        homeView.refreshControl.addTarget(
            self,
            action: #selector(refreshHomeData),
            for: .valueChanged
        )
    }

    private func setupActions() {
        // 첫 번째 취미 버튼
        homeView.firstHobbyButton.addTarget(
            self,
            action: #selector(firstHobbyTapped),
            for: .touchUpInside
        )

        // 두 번째 취미 버튼
        homeView.secondHobbyButton.addTarget(
            self,
            action: #selector(secondHobbyTapped),
            for: .touchUpInside
        )

        // 취미 추가 버튼 (No hobby state)
        homeView.addHobbyButton.addTarget(
            self,
            action: #selector(addHobbyButtonTapped),
            for: .touchUpInside
        )

        // 설정 버튼
        homeView.settingsButton.addTarget(
            self,
            action: #selector(settingsButtonTapped),
            for: .touchUpInside
        )

        // 알림 버튼
        homeView.notificationButton.addTarget(
            self,
            action: #selector(notificationTapped),
            for: .touchUpInside
        )

        // 나의 취미활동 쉐브론
        homeView.myActivityChevronButton.addTarget(
            self,
            action: #selector(myActivityChevronTapped),
            for: .touchUpInside
        )

        // 활동 드롭다운 버튼
        homeView.activityDropdownButton.addTarget(
            self,
            action: #selector(activityDropdownTapped),
            for: .touchUpInside
        )

        // 취미활동 추가하기 버튼
        homeView.addActivityButton.addTarget(
            self,
            action: #selector(addActivityButtonTapped),
            for: .touchUpInside
        )

        // Floating Action Button
        homeView.floatingActionButton.onTap = { [weak self] in
            self?.toggleFloatingMenu()
        }

        // Dim overlay tap to dismiss
        let dimTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissFloatingMenu)
        )
        homeView.dimOverlayView.addGestureRecognizer(dimTapGesture)

        // Floating Action Menu
        homeView.floatingActionMenu.onActionSelected = { [weak self] actionType in
            self?.handleFloatingMenuAction(actionType)
        }

        // AI 검색바 탭
        homeView.toastView.onTap = { [weak self] in
            self?.showAIRecommendationModal()
        }
    }

    private func setupStickerBoardCallbacks() {
        // 스티커판에서 활동 상세 화면으로 이동
        stickerBoardViewModel.onNavigateToActivityDetail = { [weak self] activityRecordId in
            self?.coordinator?.showActivityDetail(activityRecordId: activityRecordId)
        }

        // 스티커판에서 활동 기록 화면으로 이동
        stickerBoardViewModel.onNavigateToActivityRecord = { [weak self] in
            self?.coordinator?.showActivityRecord()
        }
    }
    
    private func bind() {
        // 홈 정보 업데이트
        viewModel.$homeInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] homeInfo in
                self?.updateUI(with: homeInfo)
            }
            .store(in: &cancellables)

        // 로딩 상태
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: 로딩 인디케이터 표시
                print("로딩 상태: \(isLoading)")
            }
            .store(in: &cancellables)

        // 에러 처리
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                print("❌ 에러: \(error)")
                self?.handleAppError(error)
            }
            .store(in: &cancellables)

        // 토스트 메시지 순환
        viewModel.$currentToastMessage
            .receive(on: DispatchQueue.main)
            .dropFirst() // 초기값 무시
            .sink { [weak self] message in
                self?.homeView.toastView.updateMessage(with: message, animated: true)
            }
            .store(in: &cancellables)

        // AppEventBus 이벤트 구독
        bindAppEvents()

        // 스티커판 상태 바인딩
        bindStickerBoard()
    }

    private func bindAppEvents() {
        // 바텀시트에서 활동 저장 후 홈 새로고침
        // (바텀시트 dismiss 시 viewWillAppear가 호출되지 않으므로 이벤트로 처리)
        AppEventBus.shared.activityRecordCreated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hobbyId in
                print("🔄 활동 기록 생성됨 - 홈 새로고침 (hobbyId: \(hobbyId))")
                self?.loadHomeData(hobbyId: hobbyId)
            }
            .store(in: &cancellables)

        // 활동 생성됨 - 홈으로 돌아왔을 때 드롭다운의 첫번째 항목을 선택해야 함
        AppEventBus.shared.activityCreated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.shouldSelectFirstActivity = true
            }
            .store(in: &cancellables)

        // NOTE: activityDeleted, hobbyCreated, hobbySettingsUpdated, hobbyDeleted 등
        // Navigation push/fullscreen modal에서 발생하는 이벤트는
        // dismiss/pop 시 viewWillAppear에서 currentHobbyId를 유지하며 자동 새로고침됨 → 별도 구독 불필요
    }

    private func bindStickerBoard() {
        // 스티커판 View State
        stickerBoardViewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateStickerBoardUI(state: state)
            }
            .store(in: &cancellables)

        // 스티커판 데이터
        stickerBoardViewModel.$stickerBoard
            .receive(on: DispatchQueue.main)
            .sink { [weak self] board in
                guard let self = self, let board = board else { return }
                self.homeView.stickerBoardView.configure(
                    with: board,
                    onPreviousPage: { [weak self] in
                        Task { [weak self] in
                            await self?.stickerBoardViewModel.loadPreviousPage()
                        }
                    },
                    onNextPage: { [weak self] in
                        Task { [weak self] in
                            await self?.stickerBoardViewModel.loadNextPage()
                        }
                    },
                    onStickerTap: { [weak self] index in
                        self?.stickerBoardViewModel.didTapSticker(at: index)
                    }
                )
            }
            .store(in: &cancellables)
    }

    private func updateStickerBoardUI(state: StickerBoardViewModel.ViewState) {
        switch state {
        case .loading:
            homeView.stickerBoardView.showLoading()

        case .loaded:
            // stickerBoard 바인딩에서 처리됨
            break

        case .noHobby:
            homeView.stickerBoardView.showNoHobby()

        case .empty:
            if let board = stickerBoardViewModel.stickerBoard {
                homeView.stickerBoardView.showEmpty(board: board)
            }

        case .error:
            if let errorMessage = stickerBoardViewModel.errorMessage {
                homeView.stickerBoardView.showError(message: errorMessage)
            }
        }
    }

    private func updateUI(with homeInfo: HomeInfo?) {
        guard let homeInfo = homeInfo else {
            // Handle server error - show no hobby state
            handleNoHobbyState()
            return
        }

        let hasHobbies = !homeInfo.inProgressHobbies.isEmpty

        // 취미 리스트 업데이트
        homeView.updateHobbies(homeInfo.inProgressHobbies)

        // 활동 미리보기 업데이트 (버튼 텍스트도 함께 업데이트됨)
        homeView.updateActivityPreview(homeInfo.activityPreview)

        // 취미가 없을 때만 버튼 텍스트를 "취미 추가하기"로 변경
        if !hasHobbies {
            homeView.updateAddActivityButtonTitle(hasHobbies: false)
        }

        // AI 추천 토스트 설정 및 펼치기 애니메이션
        homeView.configureToast(with: homeInfo.greetingMessage, aiCallRemaining: homeInfo.aiCallRemaining)
        homeView.toastView.setInteractionEnabled(hasHobbies)  // 취미 있을 때만 터치 활성화
        // 약간의 딜레이 후 펼치기 애니메이션 및 메시지 순환 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.homeView.expandToast(animated: true)
            self?.viewModel.startToastMessageRotation()
        }

        // Update floating button state
        updateFloatingButtonState(enabled: hasHobbies)

        // Update TabBar recording button state
        coordinator?.updateTabBarRecordingButtonState(enabled: hasHobbies)

        // 스티커 개수 업데이트
//        homeView.updateStickerCount(homeInfo.totalStickerNum)
    }

    private func handleNoHobbyState() {
        // Show no hobby UI
        homeView.updateHobbies([])
        homeView.updateActivityPreview(nil)
        homeView.updateAddActivityButtonTitle(hasHobbies: false)
        viewModel.stopToastMessageRotation()
        homeView.collapseToast(animated: false)
        homeView.hideFloatingMenu()

        // Disable AI toast interaction (no dim, just disable tap)
        homeView.toastView.setInteractionEnabled(false)

        // Disable floating button
        updateFloatingButtonState(enabled: false)

        // Disable TabBar recording button
        coordinator?.updateTabBarRecordingButtonState(enabled: false)
    }

    private func updateFloatingButtonState(enabled: Bool) {
        homeView.floatingActionButton.isUserInteractionEnabled = enabled
        homeView.floatingActionButton.alpha = enabled ? 1.0 : 0.4
    }
}

// Actions

extension HomeViewController {
    @objc private func refreshHomeData() {
        Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.fetchHomeInfo(hobbyId: self.viewModel.currentHobbyId)
            await self.stickerBoardViewModel.loadInitialStickerBoard(hobbyId: self.viewModel.currentHobbyId)
            await MainActor.run { [weak self] in
                self?.homeView.refreshControl.endRefreshing()
            }
        }
    }

    @objc private func addHobbyButtonTapped() {
        print("취미 추가 탭")
        coordinator?.showAddHobbyOnboarding()
    }

    @objc private func firstHobbyTapped() {
        guard let homeInfo = viewModel.homeInfo, !homeInfo.inProgressHobbies.isEmpty else {
            return
        }

        let firstHobby = homeInfo.inProgressHobbies[0]
        print("첫 번째 취미 탭: \(firstHobby.hobbyName)")

        // 이미 선택된 취미면 무시
        if firstHobby.currentHobby {
            return
        }

        // 취미 선택
        Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.selectHobby(hobbyId: firstHobby.hobbyId)
            await self.stickerBoardViewModel.loadInitialStickerBoard(hobbyId: firstHobby.hobbyId)
        }
    }

    @objc private func secondHobbyTapped() {
        guard let homeInfo = viewModel.homeInfo, homeInfo.inProgressHobbies.count >= 2 else {
            return
        }

        let secondHobby = homeInfo.inProgressHobbies[1]
        print("두 번째 취미 탭: \(secondHobby.hobbyName)")

        // 이미 선택된 취미면 무시
        if secondHobby.currentHobby {
            return
        }

        // 취미 선택
        Task { [weak self] in
            guard let self = self else { return }
            await self.viewModel.selectHobby(hobbyId: secondHobby.hobbyId)
            await self.stickerBoardViewModel.loadInitialStickerBoard(hobbyId: secondHobby.hobbyId)
        }
    }

    @objc private func settingsButtonTapped() {
        toggleSettingsDropdown()
    }

    private func toggleSettingsDropdown() {
        if settingsDropdownView != nil {
            dismissSettingsDropdown()
        } else {
            showSettingsDropdown()
        }
    }

    private func showSettingsDropdown() {
        dismissSettingsDropdown() // 기존 드롭다운이 있으면 먼저 제거

        // 투명 배경 생성
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        view.addSubview(backgroundView)

        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSettingsDropdown))
        backgroundView.addGestureRecognizer(tapGesture)

        // 메뉴 아이템 결정 (진행 중인 취미가 2개 이상이면 addHobby 제외)
        let inProgressCount = viewModel.homeInfo?.inProgressHobbies.count ?? 0
        let menuItems: [HomeSettingsMenuItem]
        if inProgressCount > 1 {
            menuItems = HomeSettingsMenuItem.allCases.filter { $0 != .addHobby }
        } else {
            menuItems = HomeSettingsMenuItem.allCases
        }

        // 드롭다운 생성
        let dropdownView = DropdownMenuView(items: menuItems)
        dropdownView.onItemSelected = { [weak self] menuItem in
            self?.handleSettingsDropdownOption(menuItem)
        }

        // 드롭다운 표시
        dropdownView.showInParent(view, below: homeView.settingsButton)

        // 참조 저장
        settingsDropdownBackgroundView = backgroundView
        settingsDropdownView = dropdownView
    }

    @objc private func dismissSettingsDropdown() {
        settingsDropdownView?.dismiss()
        settingsDropdownBackgroundView?.removeFromSuperview()
        settingsDropdownView = nil
        settingsDropdownBackgroundView = nil
    }

    private func handleSettingsDropdownOption(_ item: HomeSettingsMenuItem) {
        dismissSettingsDropdown()

        switch item {
        case .manageHobby:
            coordinator?.showHobbySettings()

        case .addHobby:
            coordinator?.showAddHobbyOnboarding()

        case .generalSettings:
            coordinator?.showGeneralSettings()
        }
    }

    @objc private func notificationTapped() {
        print("알림 탭")
        // TODO: 알림 화면
    }
    
    @objc private func myActivityChevronTapped() {
        print("나의 취미활동 쉐브론 탭")
        presentActivityList()
    }

    @objc private func activityDropdownTapped() {
        print("활동 드롭다운 탭")
        showActivityDropdown()
    }

    private func showActivityDropdown() {
        // 기존 드롭다운이 있으면 먼저 제거
        dismissActivityDropdown()

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let activities = try await self.viewModel.fetchActivityList()

                await MainActor.run { [weak self] in
                    self?.presentActivityDropdown(activities: activities)
                }
            } catch {
                await MainActor.run {
                    print("❌ 활동 목록 로드 실패: \(error)")
                }
            }
        }
    }

    /// 활동 생성 후 홈으로 돌아왔을 때 드롭다운의 첫번째 항목(가장 최근 추가된 항목)을 선택 (async 버전)
    private func selectFirstActivityAsync() async {
        do {
            let activities = try await viewModel.fetchActivityList()

            await MainActor.run {
                guard let firstActivity = activities.first else { return }
                self.selectActivity(firstActivity)
                print("✅ 첫번째 활동 자동 선택: \(firstActivity.content)")
            }
        } catch {
            await MainActor.run {
                print("❌ 활동 목록 로드 실패 (첫번째 활동 선택): \(error)")
            }
        }
    }

    private func presentActivityDropdown(activities: [Activity]) {
        // 투명 배경 생성
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        view.addSubview(backgroundView)

        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissActivityDropdown)
        )
        backgroundView.addGestureRecognizer(tapGesture)

        // 드롭다운 생성
        let dropdownView = ActivityDropdownView(activities: activities)
        dropdownView.onActivitySelected = { [weak self] activity in
            self?.selectActivity(activity)
        }

        // 드롭다운 표시
        dropdownView.show(in: view, below: homeView.activityDropdownButton)

        // 프로퍼티에 참조 저장
        self.dropdownBackgroundView = backgroundView
        self.activityDropdownView = dropdownView
    }

    @objc private func dismissActivityDropdown() {
        // 드롭다운 애니메이션으로 닫기
        activityDropdownView?.dismiss()

        // 배경 제거
        dropdownBackgroundView?.removeFromSuperview()

        // 참조 해제
        activityDropdownView = nil
        dropdownBackgroundView = nil
    }

    private func selectActivity(_ activity: Activity) {
        // 드롭다운 닫기
        dismissActivityDropdown()

        // ActivityPreview 객체 생성
        let activityPreview = ActivityPreview(
            activityId: activity.activityId,
            content: activity.content,
            aiRecommended: activity.aiRecommended
        )

        // HomeInfo 업데이트
        if let homeInfo = viewModel.homeInfo {
            let updatedHomeInfo = HomeInfo(
                inProgressHobbies: homeInfo.inProgressHobbies,
                activityPreview: activityPreview,
                greetingMessage: homeInfo.greetingMessage,
                userSummaryText: homeInfo.userSummaryText,
                recommendMessage: homeInfo.recommendMessage,
                aiCallRemaining: homeInfo.aiCallRemaining,
                aiCallRemainingCount: homeInfo.aiCallRemainingCount
            )

            viewModel.homeInfo = updatedHomeInfo
            homeView.updateActivityPreview(activityPreview)

            print("✅ 활동 선택 완료: \(activity.content)")
        }
    }

    private func presentActivityList() {
        guard let hobbyId = viewModel.currentHobbyId else {
            print("❌ 취미 ID 없음")
            return
        }

        let hobbyName = viewModel.homeInfo?.inProgressHobbies.first(where: { $0.currentHobby })?.hobbyName ?? "취미"

        let activityListVC = ActivityListViewController(hobbyId: hobbyId, hobbyName: hobbyName)
        activityListVC.hidesBottomBarWhenPushed = true  // 탭바 숨김

        // Push to navigation stack (스와이프 백 지원)
        navigationController?.pushViewController(activityListVC, animated: true)
    }
    
    @objc private func addActivityButtonTapped() {
        // Check if user has hobbies
        guard let homeInfo = viewModel.homeInfo, !homeInfo.inProgressHobbies.isEmpty else {
            // No hobbies - show onboarding
            print("취미 추가하기 탭")
            coordinator?.showAddHobbyOnboarding()
            return
        }

        // activityPreview 유무에 따라 다른 동작
        if homeInfo.activityPreview != nil {
            // 오늘의 스티커 붙이기 → ActivityRecord 화면으로 이동
            print("오늘의 스티커 붙이기 탭")
            coordinator?.showActivityRecord()
        } else {
            // 취미활동 추가하기 → Activity 입력 화면으로 이동
            print("취미활동 추가하기 탭")
            showActivityInput()
        }
    }

    private func showActivityInput() {
        guard let hobbyId = viewModel.currentHobbyId else {
            print("❌ 취미 ID 없음")
            return
        }

        let hobbyName = viewModel.homeInfo?.inProgressHobbies.first(where: { $0.currentHobby })?.hobbyName ?? "취미"

        let inputVC = HobbyActivityInputViewController(hobbyId: hobbyId, hobbyName: hobbyName)
        inputVC.aiCallRemaining = viewModel.homeInfo?.aiCallRemaining ?? true
        inputVC.onActivityCreated = { [weak self] in
            // Dismiss modal first, then present ActivityListViewController
            self?.dismiss(animated: true) {
                // Notify Home to update dropdown selection when returning
                AppEventBus.shared.activityCreated.send(hobbyId)
                self?.presentActivityList()
            }
        }

        let nav = BaseNavigationController(rootViewController: inputVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func showAIRecommendationModal() {
        let aiCallRemainingCount = viewModel.homeInfo?.aiCallRemainingCount ?? 0

        let containerVC = AIRecommendationContainerViewController(
            viewModel: viewModel,
            aiCallRemainingCount: aiCallRemainingCount
        )
        containerVC.modalPresentationStyle = .pageSheet

        // 활동리스트로 이동 콜백
        containerVC.onNavigateToActivityList = { [weak self] in
            self?.presentActivityList()
        }

        if let sheet = containerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        present(containerVC, animated: true)
    }

    /// 오늘 활동 기록 완료 여부 확인
    func isActivityRecordedToday() -> Bool {
        return stickerBoardViewModel.stickerBoard?.activityRecordedToday == true
    }

    /// 가장 최근(마지막) 스티커의 활동 기록 ID 반환
    func getLastActivityRecordId() -> Int? {
        return stickerBoardViewModel.stickerBoard?.stickers.last?.activityRecordId
    }

    // MARK: - Floating Action Menu

    private func toggleFloatingMenu() {
        if homeView.floatingActionButton.isExpanded {
            dismissFloatingMenu()
        } else {
            homeView.showFloatingMenu()
        }
    }

    @objc private func dismissFloatingMenu() {
        homeView.hideFloatingMenu()
    }

    private func handleFloatingMenuAction(_ actionType: FloatingActionMenu.ActionType) {
        dismissFloatingMenu()

        switch actionType {
        case .addActivity:
            showActivityInputFromFloatingButton()

        case .viewActivityList:
            presentActivityList()
        }
    }

    private func showActivityInputFromFloatingButton() {
        guard let hobbyId = viewModel.currentHobbyId else {
            print("❌ 취미 ID 없음")
            return
        }

        let hobbyName = viewModel.homeInfo?.inProgressHobbies.first(where: { $0.currentHobby })?.hobbyName ?? "취미"

        let inputVC = HobbyActivityInputViewController(hobbyId: hobbyId, hobbyName: hobbyName)
        inputVC.aiCallRemaining = viewModel.homeInfo?.aiCallRemaining ?? true
        inputVC.onActivityCreated = { [weak self] in
            // Dismiss modal first, then present ActivityListViewController
            self?.dismiss(animated: true) {
                // Notify Home to update dropdown selection when returning
                AppEventBus.shared.activityCreated.send(hobbyId)
                self?.presentActivityList()
            }
        }

        let nav = BaseNavigationController(rootViewController: inputVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    // Public Methods

    func getCurrentHobbyId() -> Int? {
        return viewModel.currentHobbyId
    }

    func getCurrentHobbyName() -> String? {
        return viewModel.homeInfo?.inProgressHobbies.first(where: { $0.currentHobby })?.hobbyName
    }

    func getCurrentActivityId() -> Int? {
        return viewModel.homeInfo?.activityPreview?.activityId
    }

    func getCurrentNickname() -> String? {
        // greetingMessage에서 닉네임 추출 (예: "유지님, 안녕하세요!" → "유지")
        guard let greetingMessage = viewModel.homeInfo?.greetingMessage else { return nil }

        // "님" 전까지의 문자열을 닉네임으로 추출
        if let range = greetingMessage.range(of: "님") {
            return String(greetingMessage[..<range.lowerBound])
        }
        return nil
    }

    /// 계정 전환 시 홈 상태 초기화 (이전 사용자의 hobbyId 제거 후 새로고침)
    func resetForAccountSwitch() {
        viewModel.currentHobbyId = nil
        loadHomeData(hobbyId: nil)
    }
}

#Preview {
    HomeViewController()
}
