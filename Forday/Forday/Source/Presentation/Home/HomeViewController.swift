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
    
    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // Activity Dropdown
    private var dropdownBackgroundView: UIView?
    private var activityDropdownView: ActivityDropdownView?

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

        // 홈 정보 로드
        Task {
            await viewModel.fetchHomeInfo()
            // fetchHomeInfo 완료 후 currentHobbyId를 stickerBoardViewModel에 전달
            await stickerBoardViewModel.loadInitialStickerBoard(hobbyId: viewModel.currentHobbyId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
                self?.handleError(error)
            }
            .store(in: &cancellables)

        // 스티커판 상태 바인딩
        bindStickerBoard()

        // 이벤트 구독
        setupEventBus()
    }

    // MARK: - Event Subscriptions
    // 구독 중인 이벤트:
    // - activityRecordCreated: 활동 기록 생성 시 스티커 보드 새로고침
    // - hobbySettingsUpdated: 취미 설정 변경 시 홈 정보 새로고침
    // - hobbyCreated: 새 취미 생성 시 홈 정보 및 스티커 보드 새로고침
    // - hobbyDeleted: 취미 삭제 시 홈 정보 및 스티커 보드 새로고침
    // - activityUpdated: 활동 수정 시 홈 정보 새로고침
    // - activityDeleted: 활동 삭제 시 홈 정보 새로고침

    private func setupEventBus() {
        // 활동 기록 생성 이벤트 구독
        AppEventBus.shared.activityRecordCreated
            .sink { [weak self] hobbyId in
                print("🎉 활동 기록 생성됨! hobbyId: \(hobbyId)")
                Task {
                    // 해당 취미의 홈 정보 새로고침
                    await self?.viewModel.fetchHomeInfo(hobbyId: hobbyId)
                    // 해당 취미의 스티커 보드 새로고침
                    await self?.stickerBoardViewModel.loadInitialStickerBoard(hobbyId: hobbyId)
                }
            }
            .store(in: &cancellables)

        // 취미 설정 변경 이벤트 구독
        AppEventBus.shared.hobbySettingsUpdated
            .sink { [weak self] hobbyId in
                print("⚙️ 취미 설정 변경됨! hobbyId: \(hobbyId)")
                Task {
                    // 해당 취미의 홈 정보 새로고침
                    await self?.viewModel.fetchHomeInfo(hobbyId: hobbyId)
                }
            }
            .store(in: &cancellables)

        // 새 취미 생성 이벤트 구독
        AppEventBus.shared.hobbyCreated
            .sink { [weak self] hobbyId in
                print("🎉 새 취미 생성됨! hobbyId: \(hobbyId)")
                Task {
                    // 새로 생성된 취미의 홈 정보 및 스티커 보드 로드
                    await self?.viewModel.fetchHomeInfo(hobbyId: hobbyId)
                    await self?.stickerBoardViewModel.loadInitialStickerBoard(hobbyId: hobbyId)
                }
            }
            .store(in: &cancellables)

        // 취미 삭제 이벤트 구독
        AppEventBus.shared.hobbyDeleted
            .sink { [weak self] in
                print("🗑️ 취미 삭제됨!")
                Task {
                    // 홈 정보 및 스티커 보드 새로고침 (서버가 기본 취미 반환)
                    await self?.viewModel.fetchHomeInfo()
                    await self?.stickerBoardViewModel.loadInitialStickerBoard(hobbyId: self?.viewModel.currentHobbyId)
                }
            }
            .store(in: &cancellables)

        // 활동 수정 이벤트 구독
        AppEventBus.shared.activityUpdated
            .sink { [weak self] hobbyId in
                print("✏️ 활동 수정됨! hobbyId: \(hobbyId)")
                Task {
                    // 해당 취미의 홈 정보 새로고침
                    await self?.viewModel.fetchHomeInfo(hobbyId: hobbyId)
                }
            }
            .store(in: &cancellables)

        // 활동 삭제 이벤트 구독
        AppEventBus.shared.activityDeleted
            .sink { [weak self] hobbyId in
                print("🗑️ 활동 삭제됨! hobbyId: \(hobbyId)")
                Task {
                    // 해당 취미의 홈 정보 새로고침
                    await self?.viewModel.fetchHomeInfo(hobbyId: hobbyId)
                }
            }
            .store(in: &cancellables)
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
                        Task {
                            await self?.stickerBoardViewModel.loadPreviousPage()
                        }
                    },
                    onNextPage: { [weak self] in
                        Task {
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
        if hasHobbies {
            homeView.configureToast(with: homeInfo.greetingMessage, aiCallRemaining: homeInfo.aiCallRemaining)
            homeView.toastView.setInteractionEnabled(true)  // 터치 활성화
            // 약간의 딜레이 후 펼치기 애니메이션
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.homeView.expandToast(animated: true)
            }
        } else {
            // 취미가 없으면 토스트 접고 터치 비활성화
            homeView.collapseToast(animated: false)
            homeView.toastView.setInteractionEnabled(false)
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
        Task {
            defer {
                Task { @MainActor in
                    homeView.refreshControl.endRefreshing()
                }
            }

            await viewModel.fetchHomeInfo()
            await stickerBoardViewModel.loadInitialStickerBoard(hobbyId: viewModel.currentHobbyId)
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
        Task {
            await viewModel.selectHobby(hobbyId: firstHobby.hobbyId)
            await stickerBoardViewModel.loadInitialStickerBoard(hobbyId: firstHobby.hobbyId)
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
        Task {
            await viewModel.selectHobby(hobbyId: secondHobby.hobbyId)
            await stickerBoardViewModel.loadInitialStickerBoard(hobbyId: secondHobby.hobbyId)
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

        Task {
            do {
                let activities = try await viewModel.fetchActivityList()

                await MainActor.run {
                    self.presentActivityDropdown(activities: activities)
                }
            } catch {
                await MainActor.run {
                    print("❌ 활동 목록 로드 실패: \(error)")
                }
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
                aiCallRemaining: homeInfo.aiCallRemaining
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

        let activityListVC = ActivityListViewController(hobbyId: hobbyId)
        activityListVC.isPresentedModally = true
        let nav = UINavigationController(rootViewController: activityListVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
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

        let inputVC = HobbyActivityInputViewController(hobbyId: hobbyId)
        inputVC.aiCallRemaining = viewModel.homeInfo?.aiCallRemaining ?? true
        inputVC.onActivityCreated = { [weak self] in
            // Dismiss modal first, then present ActivityListViewController
            self?.dismiss(animated: true) {
                self?.presentActivityList()
            }
        }

        let nav = UINavigationController(rootViewController: inputVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func showAIRecommendationModal() {
        // AI 호출 횟수 초과 시 토스트 표시
        if viewModel.homeInfo?.aiCallRemaining == false {
            ToastView.showError(message: "AI 호출 횟수를 초과하였습니다")
            return
        }

        let containerVC = AIRecommendationContainerViewController(viewModel: viewModel)
        containerVC.modalPresentationStyle = .pageSheet

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

        let inputVC = HobbyActivityInputViewController(hobbyId: hobbyId)
        inputVC.aiCallRemaining = viewModel.homeInfo?.aiCallRemaining ?? true
        inputVC.onActivityCreated = { [weak self] in
            self?.dismiss(animated: true)
        }

        let nav = UINavigationController(rootViewController: inputVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    // Error Handling

    private func handleError(_ error: AppError) {
        let alert = UIAlertController(
            title: "오류",
            message: error.userMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // Public Methods

    func getCurrentHobbyId() -> Int? {
        return viewModel.currentHobbyId
    }
}

#Preview {
    HomeViewController()
}
