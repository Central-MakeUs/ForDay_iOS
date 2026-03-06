//
//  AIRecommendationContainerViewController.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import Combine
import SnapKit

class AIRecommendationContainerViewController: UIViewController {

    // MARK: - Properties

    private var currentView: UIView?
    private var cancellables = Set<AnyCancellable>()

    private var currentStep: AIRecommendationStep = .intro {
        didSet {
            updateModalSettings()
        }
    }

    // Options
    private let skipIntro: Bool
    private let isFullscreen: Bool
    private let hobbyId: Int?
    private let hobbyName: String?
    private let aiCallRemainingCount: Int?

    // ViewModel (Home에서 사용 시)
    private let viewModel: HomeViewModel?

    // UseCase
    private let fetchAIRecommendationsUseCase: FetchAIRecommendationsUseCase
    private let fetchAIActivityItemsUseCase: FetchAIActivityItemsUseCase
    private let fetchUserProfileUseCase: FetchUserProfileUseCase

    // 캐시된 닉네임 (API 호출 후 저장)
    private var cachedNickname: String?

    // AI 추천 요청 시점의 hobbyId (dismiss 시점 재조회 방지)
    private var requestedHobbyId: Int?

    // AI 추천 결과 (직접 hobbyId 전달 시 사용)
    @Published private var aiRecommendationResult: AIRecommendationResult?
    @Published private var aiActivityItemsResult: AIActivityItemsResult?

    // Views
    private let introView = AIRecommendationIntroView()
    private let loadingView = AIRecommendationLoadingView()
    private var selectionView: AIActivitySelectionView?
    private var activityListView: AIActivityListView?

    // Callbacks
    /// 선택 모드: 선택된 활동 content를 반환 (저장하지 않음)
    var onActivitySelected: ((String) -> Void)?
    /// 활동 저장 후 ActivityList로 이동 요청
    var onNavigateToActivityList: (() -> Void)?

    // AI 추천 API 호출 여부 추적 (횟수 차감 여부)
    private var didCallAIRecommendation = false
    // 이미 이벤트를 발생시켰는지 추적 (중복 방지)
    private var didSendCompletionEvent = false
    // AI 추천 요청 중 여부 (중복 요청 방지)
    private var isLoadingAIRecommendation = false

    // MARK: - Initialization

    /// Home에서 사용 (Intro → Loading → Selection, 모달)
    init(viewModel: HomeViewModel, aiCallRemainingCount: Int) {
        self.viewModel = viewModel
        self.hobbyId = nil
        self.hobbyName = nil
        self.skipIntro = false
        self.isFullscreen = false
        self.aiCallRemainingCount = aiCallRemainingCount
        self.fetchAIRecommendationsUseCase = FetchAIRecommendationsUseCase()
        self.fetchAIActivityItemsUseCase = FetchAIActivityItemsUseCase()
        self.fetchUserProfileUseCase = FetchUserProfileUseCase()
        super.init(nibName: nil, bundle: nil)
    }

    /// ActivityList / HobbyActivityInput에서 사용 (Loading → Selection, 풀스크린)
    init(hobbyId: Int, hobbyName: String) {
        self.viewModel = nil
        self.hobbyId = hobbyId
        self.hobbyName = hobbyName
        self.skipIntro = true
        self.isFullscreen = true
        self.aiCallRemainingCount = nil
        self.fetchAIRecommendationsUseCase = FetchAIRecommendationsUseCase()
        self.fetchAIActivityItemsUseCase = FetchAIActivityItemsUseCase()
        self.fetchUserProfileUseCase = FetchUserProfileUseCase()
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .neutralWhite

        if isFullscreen {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }

        // 이전 AI 추천 결과 초기화 (새로운 세션 시작)
        viewModel?.clearAIRecommendationResult()

        // 캐시된 닉네임 초기화 (계정 전환 시 이전 사용자 데이터 노출 방지)
        cachedNickname = nil

        setupActions()
        bind()

        if skipIntro {
            startAIRecommendation()
        } else {
            showIntro()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Home에서 사용 시 + AI 추천을 호출했지만 아직 이벤트를 발생시키지 않은 경우
        // (활동을 저장하지 않고 바텀시트를 닫은 경우)
        if viewModel != nil && didCallAIRecommendation && !didSendCompletionEvent {
            if let hobbyId = requestedHobbyId {
                print("🔄 AI 추천 호출됨 (선택하지 않음) - 홈 새로고침")
                AppEventBus.shared.aiRecommendationCompleted.send(hobbyId)
                didSendCompletionEvent = true
            }
        }
    }
}

// MARK: - Setup

extension AIRecommendationContainerViewController {
    private func setupActions() {
        // Intro View - AI 추천받기 버튼
        introView.onAIRecommendTapped = { [weak self] in
            self?.startAIRecommendation()
        }

        // Intro View - 추천 받은 활동리스트 버튼
        introView.onActivityListTapped = { [weak self] in
            self?.showActivityList()
        }
    }

    private func bind() {
        if let viewModel = viewModel {
            // Home에서 사용 시 - HomeViewModel 바인딩
            viewModel.$aiRecommendationResult
                .receive(on: DispatchQueue.main)
                .compactMap { $0 }
                .sink { [weak self] result in
                    self?.showSelection(with: result)
                }
                .store(in: &cancellables)
        } else {
            // 직접 hobbyId 전달 시 - 내부 프로퍼티 바인딩
            $aiRecommendationResult
                .receive(on: DispatchQueue.main)
                .compactMap { $0 }
                .sink { [weak self] result in
                    self?.showSelection(with: result)
                }
                .store(in: &cancellables)
        }

        // AI Activity Items 바인딩
        $aiActivityItemsResult
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] result in
                self?.activityListView?.configure(with: result)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Navigation

extension AIRecommendationContainerViewController {

    private func showIntro() {
        currentStep = .intro

        // Configure intro view with aiCallRemainingCount
        if let count = aiCallRemainingCount {
            introView.configure(aiCallRemainingCount: count)
        }

        transitionToView(introView)
    }

    private func startAIRecommendation() {
        // 중복 요청 방지
        guard !isLoadingAIRecommendation else { return }
        isLoadingAIRecommendation = true

        // UI 상태 먼저 전환 (중복 호출 방지)
        currentStep = .loading

        // hobbyId 요청 시점에 저장 (dismiss 시점 재조회 방지)
        if let hobbyId = hobbyId {
            requestedHobbyId = hobbyId
        } else if let currentHobbyId = viewModel?.currentHobbyId {
            requestedHobbyId = currentHobbyId
        }

        // 취미명 결정
        let resolvedHobbyName: String
        if let hobbyName = hobbyName {
            // 직접 전달받은 hobbyName 사용
            resolvedHobbyName = hobbyName
        } else if let currentHobby = viewModel?.homeInfo?.inProgressHobbies.first(where: { $0.currentHobby }) {
            // HomeViewModel에서 현재 취미명 가져오기
            resolvedHobbyName = currentHobby.hobbyName
        } else {
            resolvedHobbyName = "취미"
        }

        // 닉네임 우선순위: 캐시 > ViewModel > API 호출
        if let cachedNickname = cachedNickname {
            // 1순위: 캐시된 닉네임
            configureLoadingViewAndFetch(nickname: cachedNickname, hobbyName: resolvedHobbyName)
        } else if let nickname = viewModel?.userInfo?.nickname {
            // 2순위: HomeViewModel에 이미 로드된 닉네임
            self.cachedNickname = nickname
            configureLoadingViewAndFetch(nickname: nickname, hobbyName: resolvedHobbyName)
        } else {
            // 3순위: API 호출 (닉네임 로드 후 화면 전환하여 깜빡임 방지)
            Task { [weak self] in
                await self?.fetchNicknameAndShowLoading(hobbyName: resolvedHobbyName)
            }
        }
    }

    private func showActivityList() {
        currentStep = .activityList

        // hobbyId 결정
        let resolvedHobbyId: Int?
        if let hobbyId = hobbyId {
            resolvedHobbyId = hobbyId
        } else {
            resolvedHobbyId = viewModel?.currentHobbyId
        }

        guard let hobbyId = resolvedHobbyId else {
            showError(NSError(domain: "AIRecommendation", code: -1, userInfo: [NSLocalizedDescriptionKey: "취미 정보를 찾을 수 없습니다."]))
            return
        }

        // Create activity list view
        let listView = AIActivityListView(hobbyId: hobbyId)

        // 저장 완료 시 바텀시트 닫지 않음 (토스트가 뷰 내에서 표시됨)
        listView.onActivitySaved = { [weak self] in
            print("✅ AI 추천 활동 저장 완료 (리스트)")
            // AI 추천 완료 이벤트 발생 (홈 데이터 새로고침 트리거)
            AppEventBus.shared.aiRecommendationCompleted.send(hobbyId)
            self?.didSendCompletionEvent = true
        }

        // 토스트 "이동하기" 버튼 클릭 시 ActivityList로 이동
        let navigateCallback = onNavigateToActivityList
        listView.onNavigateToActivityList = { [weak self] in
            self?.dismiss(animated: true) {
                navigateCallback?()
            }
        }

        listView.onError = { [weak self] errorMessage in
            self?.showError(NSError(domain: "AIRecommendation", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        }

        self.activityListView = listView
        transitionToView(listView)

        // Fetch AI activity items
        Task { [weak self] in
            await self?.fetchAIActivityItems(hobbyId: hobbyId)
        }
    }

    private func configureLoadingViewAndFetch(nickname: String, hobbyName: String) {
        // isFullscreen이면 토스트 표시, 아니면 토스트만 숨김
        loadingView.configure(nickname: nickname, hobbyName: hobbyName, showToast: isFullscreen)
        transitionToView(loadingView)

        // API 호출
        Task { [weak self] in
            await self?.fetchAIRecommendationsAsync()
        }
    }

    /// 닉네임을 먼저 로드한 후 로딩 화면 표시 (깜빡임 방지)
    private func fetchNicknameAndShowLoading(hobbyName: String) async {
        // 닉네임 먼저 가져오기
        let nickname: String
        do {
            let userInfo = try await fetchUserProfileUseCase.execute()
            nickname = userInfo.nickname
            await MainActor.run {
                self.cachedNickname = nickname
            }
        } catch {
            print("⚠️ 닉네임 로드 실패, 기본값 사용: \(error)")
            nickname = "회원"
            await MainActor.run {
                // 실패 시 캐시 초기화 (이전 사용자 데이터 노출 방지)
                self.cachedNickname = nil
            }
        }

        // 닉네임 로드 후 로딩 뷰 표시
        await MainActor.run {
            self.loadingView.configure(nickname: nickname, hobbyName: hobbyName, showToast: self.isFullscreen)
            self.transitionToView(self.loadingView)
        }

        // AI 추천 호출
        await fetchAIRecommendationsAsync()
    }

    private func fetchAIRecommendationsAsync() async {
        do {
            if let viewModel = viewModel {
                // Home에서 사용 시
                try await viewModel.fetchAIRecommendations()
                // AI 추천 성공 - 횟수가 차감됨
                await MainActor.run {
                    self.didCallAIRecommendation = true
                    self.isLoadingAIRecommendation = false
                }
            } else if let hobbyId = hobbyId {
                // 직접 hobbyId 전달 시
                let result = try await fetchAIRecommendationsUseCase.execute(hobbyId: hobbyId)
                await MainActor.run {
                    self.aiRecommendationResult = result
                    // AI 추천 성공 - 횟수가 차감됨
                    self.didCallAIRecommendation = true
                    self.isLoadingAIRecommendation = false
                }
            }
        } catch {
            // AI_CALL_LIMIT_EXCEEDED 에러 체크
            if isAICallLimitExceeded(error) {
                await handleAICallLimitExceeded()
                await MainActor.run {
                    self.isLoadingAIRecommendation = false
                }
            } else {
                await MainActor.run {
                    self.showError(error)
                    self.isLoadingAIRecommendation = false
                    if self.skipIntro {
                        self.dismiss(animated: true)
                    } else {
                        self.showIntro()
                    }
                }
            }
        }
    }

    /// AI 호출 횟수 초과 에러인지 확인
    private func isAICallLimitExceeded(_ error: Error) -> Bool {
        if let appError = error as? AppError,
           case .server(let serverError) = appError,
           serverError.errorClassName == "AI_CALL_LIMIT_EXCEEDED" {
            return true
        }
        return false
    }

    /// AI 호출 횟수 초과 시 최신 추천 목록 가져오기
    private func handleAICallLimitExceeded() async {
        guard let hobbyId = requestedHobbyId else {
            await MainActor.run {
                self.showError(NSError(domain: "AIRecommendation", code: -1, userInfo: [NSLocalizedDescriptionKey: "취미 정보를 찾을 수 없습니다."]))
                if self.skipIntro {
                    self.dismiss(animated: true)
                } else {
                    self.showIntro()
                }
            }
            return
        }

        do {
            // 최신 3개 AI 추천 활동 조회
            let latestResult = try await fetchAIActivityItemsUseCase.execute(hobbyId: hobbyId, type: "LATEST")
            let convertedResult = latestResult.toAIRecommendationResult()

            await MainActor.run {
                if self.viewModel != nil {
                    // Home에서 사용 시 - ViewModel 통해 업데이트
                    // Note: ViewModel에서는 aiRecommendationResult를 직접 설정할 수 없으므로
                    // showSelection 직접 호출
                    self.showSelection(with: convertedResult)
                } else {
                    // 직접 hobbyId 전달 시
                    self.aiRecommendationResult = convertedResult
                }
            }
        } catch {
            await MainActor.run {
                self.showError(error)
                if self.skipIntro {
                    self.dismiss(animated: true)
                } else {
                    self.showIntro()
                }
            }
        }
    }

    private func fetchAIActivityItems(hobbyId: Int) async {
        do {
            let result = try await fetchAIActivityItemsUseCase.execute(hobbyId: hobbyId, type: "ALL")
            await MainActor.run {
                self.aiActivityItemsResult = result
            }
        } catch {
            await MainActor.run {
                self.showError(error)
                self.showIntro()
            }
        }
    }


    private func showSelection(with result: AIRecommendationResult) {
        // If selectionView exists, update it (refresh case)
        if let existingView = selectionView {
            existingView.update(with: result)
            return
        }

        // Analytics: AI 추천 활동 화면 진입
        FirebaseAnalyticsService.shared.log(.aiRecommendHobbyRoutineScreen)

        // First time showing selection
        currentStep = .selection

        // hobbyId 결정
        let resolvedHobbyId: Int?
        if let hobbyId = hobbyId {
            resolvedHobbyId = hobbyId
        } else {
            resolvedHobbyId = viewModel?.currentHobbyId
        }

        guard let hobbyId = resolvedHobbyId else {
            showError(NSError(domain: "AIRecommendation", code: -1, userInfo: [NSLocalizedDescriptionKey: "취미 정보를 찾을 수 없습니다."]))
            return
        }

        // 선택 모드 vs 저장 모드
        let selectionView: AIActivitySelectionView
        if onActivitySelected != nil {
            // 선택 모드 (ActivityList / HobbyActivityInput에서 사용)
            selectionView = AIActivitySelectionView(result: result, showNavigation: isFullscreen)

            selectionView.onActivitySelected = { [weak self] content in
                self?.dismiss(animated: true) {
                    self?.onActivitySelected?(content)
                }
            }
        } else {
            // 저장 모드 (Home에서 사용)
            selectionView = AIActivitySelectionView(result: result, hobbyId: hobbyId, showNavigation: isFullscreen)

            // 저장 완료 시 바텀시트 닫지 않음 (토스트가 뷰 내에서 표시됨)
            selectionView.onActivitySaved = { [weak self] in
                print("✅ AI 추천 활동 저장 완료")
                // AI 추천 완료 이벤트 발생 (홈 데이터 새로고침 트리거)
                AppEventBus.shared.aiRecommendationCompleted.send(hobbyId)
                self?.didSendCompletionEvent = true
            }

            // 토스트 "이동하기" 버튼 클릭 시 ActivityList로 이동
            let navigateCallback = onNavigateToActivityList
            selectionView.onNavigateToActivityList = { [weak self] in
                self?.dismiss(animated: true) {
                    navigateCallback?()
                }
            }
        }

        selectionView.onBackTapped = { [weak self] in
            self?.dismiss(animated: true)
        }

        selectionView.onRefreshTapped = { [weak self] in
            self?.refreshAIRecommendation()
        }

        selectionView.onError = { [weak self] errorMessage in
            self?.showError(NSError(domain: "AIRecommendation", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        }

        self.selectionView = selectionView
        transitionToView(selectionView)
    }

    /// Refresh without transitioning to loading view (uses skeleton in selection view)
    private func refreshAIRecommendation() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                if let viewModel = self.viewModel {
                    try await viewModel.fetchAIRecommendations()
                } else if let hobbyId = self.hobbyId {
                    let result = try await self.fetchAIRecommendationsUseCase.execute(hobbyId: hobbyId)
                    await MainActor.run { [weak self] in
                        self?.aiRecommendationResult = result
                    }
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.selectionView?.hideSkeleton()
                    self?.showError(error)
                }
            }
        }
    }

    private func transitionToView(_ newView: UIView) {
        // 기존 View 제거
        currentView?.removeFromSuperview()

        // 새 View 추가
        view.addSubview(newView)
        newView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        currentView = newView
    }

    private func updateModalSettings() {
        // 풀스크린 모드에서는 sheet 설정 건너뛰기
        guard !isFullscreen else { return }

        switch currentStep {
        case .intro:
            isModalInPresentation = false
            if let sheet = sheetPresentationController {
                sheet.detents = [
                    .custom(identifier: .init("intro")) { _ in 236 }
                ]
                sheet.preferredCornerRadius = 20
                sheet.prefersGrabberVisible = true
            }

        case .loading:
            isModalInPresentation = true
            if let sheet = sheetPresentationController {
                sheet.detents = [
                    .custom(identifier: .init("loading")) { _ in 236 }
                ]
                sheet.preferredCornerRadius = 20
                sheet.prefersGrabberVisible = false
            }

        case .selection:
            isModalInPresentation = false
            if let sheet = sheetPresentationController {
                sheet.detents = [
                    .custom(identifier: .init("selection")) { context in
                        return context.maximumDetentValue * 0.8
                    }
                ]
                sheet.preferredCornerRadius = 20
                sheet.prefersGrabberVisible = true
                sheet.largestUndimmedDetentIdentifier = .large
            }

        case .activityList:
            isModalInPresentation = false
            if let sheet = sheetPresentationController {
                sheet.detents = [
                    .custom(identifier: .init("activityList")) { _ in 670 }
                ]
                sheet.preferredCornerRadius = 20
                sheet.prefersGrabberVisible = true
            }
        }
    }

    private func showError(_ error: Error) {
        let message: String
        if let appError = error as? AppError {
            message = appError.userMessage
        } else {
            message = error.localizedDescription
        }
        ToastView.showError(message: message)
    }
}
