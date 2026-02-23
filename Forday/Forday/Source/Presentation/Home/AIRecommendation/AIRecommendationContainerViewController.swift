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

        setupActions()
        bind()

        if skipIntro {
            startAIRecommendation()
        } else {
            showIntro()
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
        currentStep = .loading

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

        // 캐시된 닉네임이 있으면 바로 사용, 없으면 API 호출
        if let cachedNickname = cachedNickname {
            configureLoadingViewAndFetch(nickname: cachedNickname, hobbyName: resolvedHobbyName)
        } else {
            // 임시로 "회원" 표시 후 닉네임 로드
            loadingView.configure(nickname: "회원", hobbyName: resolvedHobbyName, showToast: isFullscreen)
            transitionToView(loadingView)

            // 닉네임 가져오기 및 AI 추천 동시 호출
            Task {
                await fetchNicknameAndAIRecommendations(hobbyName: resolvedHobbyName)
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
        listView.onActivitySaved = {
            print("✅ AI 추천 활동 저장 완료 (리스트)")
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
        Task {
            await fetchAIActivityItems(hobbyId: hobbyId)
        }
    }

    private func configureLoadingViewAndFetch(nickname: String, hobbyName: String) {
        // isFullscreen이면 토스트 표시, 아니면 토스트만 숨김
        loadingView.configure(nickname: nickname, hobbyName: hobbyName, showToast: isFullscreen)
        transitionToView(loadingView)

        // API 호출
        Task {
            await fetchAIRecommendationsAsync()
        }
    }

    private func fetchNicknameAndAIRecommendations(hobbyName: String) async {
        // 닉네임 가져오기
        do {
            let userInfo = try await fetchUserProfileUseCase.execute()
            await MainActor.run {
                self.cachedNickname = userInfo.nickname
                // 로딩 뷰 업데이트
                self.loadingView.configure(nickname: userInfo.nickname, hobbyName: hobbyName, showToast: self.isFullscreen)
            }
        } catch {
            print("⚠️ 닉네임 로드 실패, 기본값 사용: \(error)")
            // 실패 시 "회원" 유지
        }

        // AI 추천 호출
        await fetchAIRecommendationsAsync()
    }

    private func fetchAIRecommendationsAsync() async {
        do {
            if let viewModel = viewModel {
                // Home에서 사용 시
                try await viewModel.fetchAIRecommendations()
            } else if let hobbyId = hobbyId {
                // 직접 hobbyId 전달 시
                let result = try await fetchAIRecommendationsUseCase.execute(hobbyId: hobbyId)
                await MainActor.run {
                    self.aiRecommendationResult = result
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
            selectionView.onActivitySaved = {
                print("✅ AI 추천 활동 저장 완료")
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
        Task {
            do {
                if let viewModel = viewModel {
                    try await viewModel.fetchAIRecommendations()
                } else if let hobbyId = hobbyId {
                    let result = try await fetchAIRecommendationsUseCase.execute(hobbyId: hobbyId)
                    await MainActor.run {
                        self.aiRecommendationResult = result
                    }
                }
            } catch {
                await MainActor.run {
                    self.selectionView?.hideSkeleton()
                    self.showError(error)
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
