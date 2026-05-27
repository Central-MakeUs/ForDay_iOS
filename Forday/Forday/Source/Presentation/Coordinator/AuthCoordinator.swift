//
//  AuthCoordinator.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import UIKit

class AuthCoordinator: Coordinator {

    let navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?

    private var onboardingCoordinator: OnboardingCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showLogin()
    }
    
    // 로그인 화면
    func showLogin() {
        let vc = LoginViewController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    // 약관동의 화면
    func showTermsAgreement() {
        let vc = TermsAgreementViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    // 로그인 성공 후 분기 처리
    func handleLoginSuccess(authToken: AuthToken) {
        print("🔵 handleLoginSuccess 호출됨")
        print("   - nicknameSet: \(authToken.nicknameSet)")
        print("   - onboardingCompleted: \(authToken.onboardingCompleted)")
        print("   - termsConsentCompleted: \(authToken.termsConsentCompleted)")
        print("   - socialType: \(authToken.socialType)")
        print("   - guestUserId: \(authToken.guestUserId ?? "nil")")
        print("   - onboardingData: \(authToken.onboardingData != nil ? "있음" : "없음")")

        // 케이스 0: 약관 동의 필요 (신규 유저만)
        if !authToken.termsConsentCompleted && authToken.isNewUser {
            print("   ➡️ 약관동의 화면으로 이동")
            showTermsAgreement()
            return
        }

        // 케이스 1: 온보딩 미완료 → 홈 진입 금지
        if !authToken.onboardingCompleted {
            if let savedData = authToken.onboardingData {
                print("   ➡️ 온보딩 재개 (PeriodSelection으로 복원)")
                resumeOnboarding(with: savedData)
            } else {
                print("   ➡️ AB 테스트 그룹 기준 온보딩 시작")
                showAssignedOnboardingFlow(nicknameSet: authToken.nicknameSet)
            }
            return
        }

        // 케이스 2: 온보딩 완료 + 닉네임 설정 완료 → 홈
        if authToken.nicknameSet {
            print("   ➡️ 홈으로 이동")
            showHome()
            return
        }

        // 케이스 3: 온보딩 완료 + 닉네임 미설정 → 저장 데이터가 있으면 재개, 없으면 닉네임 설정
        if let savedData = authToken.onboardingData {
            print("   ➡️ 온보딩 재개 (PeriodSelection으로 복원)")
            resumeOnboarding(with: savedData)
        } else {
            print("   ➡️ 닉네임 설정 화면으로 이동")
            showNicknameSetup()
        }
    }
    
    // 온보딩 시작
    func showOnboarding() {
        let onboardingNav = UINavigationController()

        onboardingNav.modalPresentationStyle = .fullScreen

        let onboardingCoordinator = OnboardingCoordinator(navigationController: onboardingNav)
        onboardingCoordinator.parentCoordinator = self
        onboardingCoordinator.start()

        self.onboardingCoordinator = onboardingCoordinator
        navigationController.present(onboardingNav, animated: true)
    }

    // 닉네임 설정 화면 (재로그인 시)
    func showNicknameSetup() {
        let onboardingNav = UINavigationController()

        onboardingNav.modalPresentationStyle = .fullScreen

        let onboardingCoordinator = OnboardingCoordinator(navigationController: onboardingNav)
        onboardingCoordinator.parentCoordinator = self
        onboardingCoordinator.showNicknameSetup()

        self.onboardingCoordinator = onboardingCoordinator
        navigationController.present(onboardingNav, animated: true)
    }

    // 온보딩 재개 (기존 데이터로 복원)
    func resumeOnboarding(with savedData: SavedOnboardingData) {
        let onboardingNav = UINavigationController()

        onboardingNav.modalPresentationStyle = .fullScreen

        let onboardingCoordinator = OnboardingCoordinator(navigationController: onboardingNav)
        onboardingCoordinator.parentCoordinator = self
        onboardingCoordinator.resumeWith(savedData: savedData)

        self.onboardingCoordinator = onboardingCoordinator
        navigationController.present(onboardingNav, animated: true)
    }
    
    // 온보딩 완료 후 홈으로
    func completeOnboarding() {
        print("🟢 completeOnboarding 호출됨")

        // Firebase Analytics: 온보딩 완료 이벤트 로깅
        OnboardingABTest.logOnboardingCompleted()

        // 온보딩 코디네이터 참조 정리
        onboardingCoordinator = nil

        // ✅ dismiss 없이 바로 홈으로!
        parentCoordinator?.showMainTabBar()
    }
    
    // 홈 화면
    func showHome() {
        parentCoordinator?.showMainTabBar()
    }

    // 온보딩 취소 (뒤로가기) - 로그인 화면으로 돌아감
    func cancelOnboarding() {
        print("🔴 온보딩 취소 - 로그인 화면으로 돌아감")

        // 온보딩 코디네이터 참조 정리
        onboardingCoordinator = nil

        // dismiss 전에 로그인 화면 먼저 설정 (dismiss 애니메이션 중 빈 화면 방지)
        showLogin()

        // 온보딩 dismiss
        navigationController.dismiss(animated: true)
    }

    // 자동 로그인 (앱 시작 시, 토큰 valid할 때)
    func autoLogin() {
        print("🔵 autoLogin() 시작")
        print("   - 토큰 검증 완료 상태 → 홈으로 이동")
        showHome()
    }

    // MARK: - 새 온보딩 플로우 (테스트용)

    /// 새 온보딩 플로우: 약관 동의 → 닉네임 → 취미 선택 → 포비 소개
    func showNewOnboardingFlow() {
        showTermsAgreement()
    }

    func showNewOnboardingNickname() {
        let vc = NicknameViewController()
        vc.authCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func showSimpleHobbySelection() {
        let vc = SimpleHobbySelectionViewController()
        vc.authCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func showPobyIntroduction() {
        let vc = OnboardingCompleteViewController()
        vc.authCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    private func showAssignedOnboardingFlow(nicknameSet: Bool = false) {
        OnboardingABTest.getGroup { [weak self] abTestGroup in
            DispatchQueue.main.async {
                switch abTestGroup {
                case .control:
                    print("   🧪 [AB Test] 기존 플로우 진입")
                    self?.showOnboarding()
                case .variant:
                    print("   🧪 [AB Test] 신규 플로우 진입")
                    if nicknameSet {
                        self?.showSimpleHobbySelection()
                    } else {
                        self?.showNewOnboardingNickname()
                    }
                }
            }
        }
    }

    func finishNewOnboarding() {
        print("🟢 새 온보딩 플로우 완료")

        // Firebase Analytics: 온보딩 완료 이벤트 로깅
        OnboardingABTest.logOnboardingCompleted()

        // 홈으로 이동
        parentCoordinator?.showMainTabBar()
    }
}

// MARK: - TermsAgreementCoordinatorDelegate

extension AuthCoordinator: TermsAgreementCoordinatorDelegate {
    func termsAgreementDidComplete() {
        print("✅ 약관동의 완료 → 온보딩 시작")

        showAssignedOnboardingFlow()
    }

    func termsAgreementDidRequestBack() {
        print("🔙 약관동의 화면에서 뒤로가기")
        navigationController.popViewController(animated: true)
    }

    func termsAgreementDidRequestTermsDetail(type: TermsType) {
        print("📄 약관 상세 조회: \(type.title)")
        let termsVC = TermsViewController(termsType: type)
        navigationController.present(termsVC, animated: true)
    }
}
