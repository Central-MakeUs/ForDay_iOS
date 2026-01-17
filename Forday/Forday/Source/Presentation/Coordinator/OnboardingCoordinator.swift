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
    
    // Initialization
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // Coordinator
    
    func start() {
        show(.hobby)
    }
    
    // Navigation
    
    func show(_ step: OnboardingStep) {
        let vc: UIViewController
        
        switch step {
        case .hobby:
            let viewModel = HobbySelectionViewModel()
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
            viewModel.onPurposesSelected = { [weak self] purposes in
                self?.updatePurposes(purposes)
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
                self?.next(from: .period)
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
            show(.complete)
            // Complete 화면이 push 완료된 후 스택 정리
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.removeOnboardingStepsFromStack()
            }
        case .complete:
            break
        }
    }
    
    // 닉네임 설정 화면으로
    func showNicknameSetup() {
        let vc = NicknameViewController()
        vc.coordinator = self
        
        // Complete 화면 제거하고 Nickname만 남기기
        var viewControllers = navigationController.viewControllers
        if let completeIndex = viewControllers.firstIndex(where: { $0 is OnboardingCompleteViewController }) {
            viewControllers.remove(at: completeIndex)
        }
        viewControllers.append(vc)
        navigationController.setViewControllers(viewControllers, animated: true)
    }
    
    // 닉네임 설정 완료 후 홈으로
    func completeNicknameSetup() {
        print("🔵 completeNicknameSetup 호출됨")
        print("🔵 navigationController dismiss 시작")

        // ✅ dismiss만 하고 바로 AuthCoordinator에 알림
        navigationController.dismiss(animated: true) {
            print("🔵 dismiss 완료, completeOnboarding 호출")
            self.parentCoordinator?.completeOnboarding()
        }
    }
    
    // 온보딩 단계들을 스택에서 제거
    private func removeOnboardingStepsFromStack() {
        if let completeVC = navigationController.viewControllers.last as? OnboardingCompleteViewController {
            navigationController.setViewControllers([completeVC], animated: false)
        }
    }
    
    func dismissOnboarding() {
        navigationController.dismiss(animated: true)
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
    
    func updatePurposes(_ purposes: [String]) {
        onboardingData.purposes = purposes
        print("✅ 목적 저장: \(purposes)")
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
