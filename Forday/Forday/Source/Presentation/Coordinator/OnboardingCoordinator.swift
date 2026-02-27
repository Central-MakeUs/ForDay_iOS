//
//  OnboardingCoordinator.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import UIKit

class OnboardingCoordinator: Coordinator {

    // Properties

    let navigationController: UINavigationController
    weak var parentCoordinator: AuthCoordinator?

    // 온보딩 데이터 수집
    private var onboardingData = OnboardingData()
    // 로컬 저장은 더 이상 사용하지 않음 - 서버로 직접 전송
    // private let storage = OnboardingDataStorage.shared

    // Completion handler for hobby creation (used when called from HobbySettings)
    var onHobbyCreationCompleted: (() -> Void)?

    /// 취미 선택 모드 (첫 생성 vs 추가)
    var hobbySelectionMode: HobbySelectionViewModel.Mode = .firstCreation
    
    // Initialization
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // Coordinator
    
    func start() {
        // 프로그래스바 초기화 (이전 인스턴스 제거)
        BaseOnboardingViewController.resetProgressBar()
        show(.hobby)
    }
    
    // Navigation
    
    func show(_ step: OnboardingStep) {
        let vc: UIViewController
        
        switch step {
        case .hobby:
            let viewModel = HobbySelectionViewModel(mode: hobbySelectionMode)
            viewModel.onHobbySelected = { [weak self] hobbyCard in
                self?.updateHobby(hobbyCard)
            }
            vc = HobbySelectionViewController(viewModel: viewModel)
            
        case .time:
            let viewModel = TimeSelectionViewModel()
            viewModel.onTimeSelected = { [weak self] minutes in
                self?.updateTime(minutes)
            }
            vc = TimeSelectionViewController(viewModel: viewModel)
            
        case .purpose:
            let viewModel = PurposeSelectionViewModel()
            viewModel.onPurposeSelected = { [weak self] purpose in
                self?.updatePurpose(purpose)
            }
            vc = PurposeSelectionViewController(viewModel: viewModel)
            
        case .frequency:
            let viewModel = FrequencySelectionViewModel()
            viewModel.onFrequencySelected = { [weak self] count in
                self?.updateFrequency(count)
            }
            vc = FrequencySelectionViewController(viewModel: viewModel)
            
        case .period:
            let viewModel = PeriodSelectionViewModel()
            viewModel.onPeriodSelected = { [weak self] isDurationSet in
                self?.updatePeriod(isDurationSet)
            }
            viewModel.onHobbyCreated = { [weak self] hobbyId in
                print("✅ 취미 생성 완료 - hobbyId: \(hobbyId)")

                // If called from HobbySettings, call completion handler instead of navigating
                if let completionHandler = self?.onHobbyCreationCompleted {
                    completionHandler()
                } else {
                    // Normal onboarding flow - proceed to transition screen
                    self?.showNicknameTransition()
                }
            }
            vc = PeriodSelectionViewController(viewModel: viewModel)
            
        case .complete:
            vc = OnboardingCompleteViewController()
            (vc as? OnboardingCompleteViewController)?.coordinator = self
        }
        
        // Coordinator 주입
        if let baseVC = vc as? BaseOnboardingViewController {
            baseVC.coordinator = self
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func next(from currentStep: OnboardingStep) {
        switch currentStep {
        case .hobby: show(.time)
        case .time: show(.purpose)
        case .purpose: show(.frequency)
        case .frequency: show(.period)
        case .period:
            // API 호출은 ViewModel에서 처리하고, 성공 시 onHobbyCreated 클로저를 통해 여기로 돌아옴
            // Period 완료 후 닉네임 설정 화면으로
            break
        case .complete:
            break
        }
    }
    
    // 닉네임 설정 화면으로 (progress bar 없음, 뒤로가기 불가)
    func showNicknameSetup() {
        // 프로그래스바 초기화 (재로그인 시)
        if navigationController.viewControllers.isEmpty {
            BaseOnboardingViewController.resetProgressBar()
        }

        let vc = NicknameViewController()
        vc.coordinator = self

        // 재로그인 시: 온보딩 스택 전부 제거하고 닉네임만 표시
        if navigationController.viewControllers.isEmpty {
            navigationController.setViewControllers([vc], animated: true)
        } else {
            // 온보딩 진행 중: 그냥 push
            navigationController.pushViewController(vc, animated: true)
        }
    }

    // 닉네임 전환 화면 표시
    private func showNicknameTransition() {
        let vc = NicknameTransitionViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    // 온보딩 완료 화면 표시
    func showOnboardingComplete() {
        show(.complete)
    }

    // 온보딩 완전 종료 (홈으로)
    func finishOnboarding() {
        print("✅ 온보딩 완전 종료 - 홈으로 이동")

        // dismiss하고 AuthCoordinator에 알림
        navigationController.dismiss(animated: true) {
            self.parentCoordinator?.completeOnboarding()
        }
    }
    
    func dismissOnboarding() {
        // parentCoordinator를 통해 dismiss 및 로그인 화면 복원
        if let parentCoordinator {
            parentCoordinator.cancelOnboarding()
        } else {
            // fallback: parentCoordinator가 없으면 직접 dismiss
            navigationController.dismiss(animated: true)
        }
    }

    // MARK: - Resume Onboarding with Saved Data

    /// 저장된 온보딩 데이터로 온보딩 재개
    func resumeWith(savedData: SavedOnboardingData) {
        print("🔄 온보딩 재개 시작 - 저장된 데이터로 복원")

        // 프로그래스바 초기화 (이전 인스턴스 제거)
        BaseOnboardingViewController.resetProgressBar()

        Task { [weak self] in
            guard let self = self else { return }
            do {
                // 1. 서버에서 취미 목록 가져오기
                let fetchAppMetadataUseCase = FetchAppMetadataUseCase()
                let metadata = try await fetchAppMetadataUseCase.execute()

                // 2. hobbyInfoId로 해당 HobbyCard 찾기
                guard let hobbyCard = metadata.hobbyCards.first(where: { $0.id == savedData.hobbyInfoId }) else {
                    print("❌ 취미 카드를 찾을 수 없음: \(savedData.hobbyInfoId)")
                    await MainActor.run { [weak self] in
                        self?.showNicknameSetup()  // 실패 시 닉네임 화면으로
                    }
                    return
                }

                // 3. onboardingData에 데이터 채우기
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.onboardingData.selectedHobbyCard = hobbyCard
                    self.onboardingData.timeMinutes = savedData.hobbyTimeMinutes
                    self.onboardingData.purpose = savedData.hobbyPurpose
                    self.onboardingData.executionCount = savedData.executionCount
                    self.onboardingData.isDurationSet = savedData.durationSet
                    self.onboardingData.existingHobbyId = savedData.id  // 기존 취미 ID 저장 (updateHobby 호출용)

                    print("✅ 온보딩 데이터 복원 완료:")
                    print("   - 기존 취미 ID: \(savedData.id)")
                    print("   - 취미: \(hobbyCard.name)")
                    print("   - 시간: \(savedData.hobbyTimeMinutes)분")
                    print("   - 목적: \(savedData.hobbyPurpose)")
                    print("   - 횟수: 주 \(savedData.executionCount)회")
                    print("   - 기간 설정: \(savedData.durationSet)")

                    // 4. 화면들을 스택에 쌓기
                    self.buildOnboardingStack(with: hobbyCard, allHobbies: metadata.hobbyCards, savedData: savedData)
                }
            } catch {
                print("❌ 온보딩 재개 실패: \(error)")
                await MainActor.run { [weak self] in
                    self?.showNicknameSetup()  // 실패 시 닉네임 화면으로
                }
            }
        }
    }

    /// 온보딩 화면 스택 구성
    private func buildOnboardingStack(with hobbyCard: HobbyCard, allHobbies: [HobbyCard], savedData: SavedOnboardingData) {
        var viewControllers: [UIViewController] = []

        // 1. HobbySelection (선택된 취미 표시)
        let hobbyViewModel = HobbySelectionViewModel()
        hobbyViewModel.hobbies = allHobbies
        hobbyViewModel.setInitialSelection(hobbyCard)
        hobbyViewModel.onHobbySelected = { [weak self] selectedHobby in
            self?.updateHobby(selectedHobby)
        }
        let hobbyVC = HobbySelectionViewController(viewModel: hobbyViewModel)
        hobbyVC.coordinator = self
        viewControllers.append(hobbyVC)

        // 2. TimeSelection (기존 시간 표시)
        let timeViewModel = TimeSelectionViewModel()
        timeViewModel.setInitialTime(savedData.hobbyTimeMinutes)
        timeViewModel.onTimeSelected = { [weak self] minutes in
            self?.updateTime(minutes)
        }
        let timeVC = TimeSelectionViewController(viewModel: timeViewModel)
        timeVC.coordinator = self
        viewControllers.append(timeVC)

        // 3. PurposeSelection (기존 목적 표시)
        let purposeViewModel = PurposeSelectionViewModel()
        purposeViewModel.setInitialPurpose(savedData.hobbyPurpose)
        purposeViewModel.onPurposeSelected = { [weak self] purpose in
            self?.updatePurpose(purpose)
        }
        let purposeVC = PurposeSelectionViewController(viewModel: purposeViewModel)
        purposeVC.coordinator = self
        viewControllers.append(purposeVC)

        // 4. FrequencySelection (기존 횟수 표시)
        let frequencyViewModel = FrequencySelectionViewModel()
        frequencyViewModel.setInitialFrequency(savedData.executionCount)
        frequencyViewModel.onFrequencySelected = { [weak self] count in
            self?.updateFrequency(count)
        }
        let frequencyVC = FrequencySelectionViewController(viewModel: frequencyViewModel)
        frequencyVC.coordinator = self
        viewControllers.append(frequencyVC)

        // 5. PeriodSelection (현재 보여줄 화면)
        let periodViewModel = PeriodSelectionViewModel()
        periodViewModel.onPeriodSelected = { [weak self] isDurationSet in
            self?.updatePeriod(isDurationSet)
        }
        periodViewModel.onHobbyCreated = { [weak self] hobbyId in
            print("✅ 취미 수정 완료 - hobbyId: \(hobbyId)")
            self?.showNicknameTransition()
        }
        let periodVC = PeriodSelectionViewController(viewModel: periodViewModel)
        periodVC.coordinator = self
        viewControllers.append(periodVC)

        // 스택에 모두 추가 (animated: false)
        navigationController.setViewControllers(viewControllers, animated: false)

        print("✅ 온보딩 화면 스택 구성 완료 - PeriodSelection 화면 표시")
    }
}

// MARK: - Data Collection

extension OnboardingCoordinator {
    
    func updateHobby(_ hobbyCard: HobbyCard) {
        onboardingData.selectedHobbyCard = hobbyCard
        print("✅ 취미 저장: \(hobbyCard.name)")
    }
    
    func updateTime(_ minutes: Int) {
        onboardingData.timeMinutes = minutes
        print("✅ 시간 저장: \(minutes)분")
    }
    
    func updatePurpose(_ purpose: String) {
        onboardingData.purpose = purpose
        print("✅ 목적 저장: \(purpose)")
    }
    
    func updateFrequency(_ count: Int) {
        onboardingData.executionCount = count
        print("✅ 횟수 저장: 주 \(count)회")
    }
    
    func updatePeriod(_ isDurationSet: Bool) {
        onboardingData.isDurationSet = isDurationSet
        print("✅ 기간 저장: \(isDurationSet)")
    }

    // 온보딩 데이터 getter - ViewModel에서 사용
    func getOnboardingData() -> OnboardingData {
        return onboardingData
    }

    // 로컬 저장은 더 이상 사용하지 않음 - 서버로 직접 전송
    // private func saveOnboardingData() {
    //     do {
    //         try storage.save(onboardingData)
    //         print("✅ 온보딩 데이터 저장 완료")
    //         print("저장된 데이터: \(onboardingData)")
    //     } catch {
    //         print("❌ 온보딩 데이터 저장 실패: \(error)")
    //     }
    // }
}
