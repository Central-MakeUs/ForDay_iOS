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

        // 스플래시 화면 표시
        showSplash()
    }

    // 스플래시 화면
    private func showSplash() {
        let splashVC = SplashViewController()
        splashVC.onSplashComplete = { [weak self] in
            self?.checkAutoLogin()
        }
        window.rootViewController = splashVC
    }

    // 자동 로그인 체크
    private func checkAutoLogin() {
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
