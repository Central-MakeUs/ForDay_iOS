//
//  AppCoordinator.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import UIKit

class AppCoordinator: Coordinator {
    
    let window: UIWindow
    let navigationController: UINavigationController
    
    private var authCoordinator: AuthCoordinator?
    private var mainTabBarCoordinator: MainTabBarCoordinator?
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func start() {
        print("🟣 AppCoordinator start")

        // window 배경색 설정 (화면 전환 시 흰색 깜빡임 방지)
        window.backgroundColor = .bg004

        // 스플래시 화면 표시
        showSplash()
    }

    // 스플래시 화면
    private func showSplash() {
        let splashVC = SplashViewController()
        splashVC.onSplashComplete = { [weak self] in
            self?.checkVersionPolicy()
        }
        window.rootViewController = splashVC
    }

    // 버전 정책 체크
    private func checkVersionPolicy() {
        let useCase = CheckVersionPolicyUseCase()

        Task { [weak self] in
            let policy = await useCase.execute()

            await MainActor.run { [weak self] in
                guard let self = self else { return }

                // API 실패 또는 업데이트 불필요 시 정상 진행
                guard let policy = policy else {
                    self.checkAutoLogin()
                    return
                }

                switch policy.updateType {
                case .none:
                    print("🟢 업데이트 불필요 - 정상 진행")
                    self.checkAutoLogin()

                case .recommend:
                    print("🟡 권장 업데이트 - 팝업 표시")
                    self.showUpdatePopup(
                        type: .recommend(storeUrl: policy.storeUrl, message: policy.message)
                    )

                case .force:
                    print("🔴 강제 업데이트 - 팝업 표시")
                    self.showUpdatePopup(
                        type: .force(storeUrl: policy.storeUrl, message: policy.message)
                    )

                case .block:
                    print("🔴 서비스 점검 - 팝업 표시")
                    self.showUpdatePopup(
                        type: .block(message: policy.message)
                    )
                }
            }
        }
    }

    // 업데이트 팝업 표시
    private func showUpdatePopup(type: VersionUpdatePopupViewController.UpdateType) {
        let popup = VersionUpdatePopupViewController(updateType: type)

        switch type {
        case .recommend:
            popup.onLaterTapped = { [weak self] in
                self?.checkAutoLogin()
            }
            popup.onUpdateTapped = {
                // 앱스토어로 이동 후 앱 유지
            }

        case .force:
            popup.onUpdateTapped = {
                // 앱스토어로 이동 후 앱 유지
            }

        case .block:
            popup.onConfirmTapped = {
                // 앱 종료
                exit(0)
            }
        }

        window.rootViewController?.present(popup, animated: true)
    }

    // 앱 소개 체크
    private func checkAutoLogin() {
        // 앱 소개를 본 적이 없으면 먼저 앱 소개 표시
        if !AppLaunchStorage.shared.hasSeenAppIntro {
            showAppIntro()
        } else {
            proceedToLogin()
        }
    }

    // 앱 소개 화면
    private func showAppIntro() {
        let appIntroVC = AppIntroViewController()
        appIntroVC.onIntroComplete = { [weak self] in
            // 앱 소개 완료 후 자동 로그인 체크
            self?.proceedToLogin()
        }
        window.rootViewController = appIntroVC
    }

    // 자동 로그인 체크
    private func proceedToLogin() {
        let autoLoginUseCase = AuthUseCaseFactory().makeAutoLoginUseCase()

        Task { [weak self] in
            let result = await autoLoginUseCase.execute()

            await MainActor.run { [weak self] in
                switch result {
                case .success:
                    print("🟢 AppCoordinator - 자동 로그인 성공")
                    self?.performAutoLogin()

                case .needsLogin:
                    print("🔴 AppCoordinator - 로그인 필요")
                    self?.showAuth()
                }
            }
        }
    }

    // 자동 로그인 처리 (토큰 유효 확인 후 호출)
    private func performAutoLogin() {
        window.rootViewController = navigationController
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        authCoordinator.autoLogin()
        self.authCoordinator = authCoordinator
    }
    
    // 인증 화면 (로그인)
    func showAuth() {
        print("show auth")
        window.rootViewController = navigationController
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        authCoordinator.start()
        self.authCoordinator = authCoordinator
    }
    
    // 메인 화면 (홈)
    func showMainTabBar() {
        print("🟡 showMainTabBar 호출됨")

        let mainTabBarCoordinator = MainTabBarCoordinator(navigationController: navigationController)
        mainTabBarCoordinator.parentCoordinator = self
        mainTabBarCoordinator.start()

        print("🟡 window.rootViewController = tabBarController 실행")
        window.rootViewController = mainTabBarCoordinator.tabBarController
        self.mainTabBarCoordinator = mainTabBarCoordinator

        print("🟡 showMainTabBar 완료")
    }
    
    // 로그아웃
    func logout() {
        do {
            // 게스트 사용자인지 확인
            let isGuest = TokenStorage.shared.loadGuestUserId() != nil

            // 토큰만 삭제 (guestUserId는 유지)
            try TokenStorage.shared.deleteTokens()

            if isGuest {
                print("🔧 [DEBUG] 게스트 토큰 삭제됨 (guestUserId 유지) - 로그인 화면으로 이동")
            } else {
                print("🔧 [DEBUG] 토큰 삭제됨 - 로그인 화면으로 이동")
            }

            // 기존 coordinator 정리 후 인증 화면으로 전환
            mainTabBarCoordinator = nil
            authCoordinator = nil
            showAuth()

        } catch {
            print("로그아웃 실패: \(error)")
        }
    }
}
