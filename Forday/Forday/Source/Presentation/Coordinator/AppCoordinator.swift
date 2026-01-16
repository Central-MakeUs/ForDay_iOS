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
        print("AppCoordinator start")
        // 토큰 확인
        if isLoggedIn() {
            showMainTabBar()
        } else {
            showAuth()
        }
        
        window.rootViewController = navigationController
//        window.makeKeyAndVisible()
    }
    
    // 로그인 여부 확인
    private func isLoggedIn() -> Bool {
        do {
            _ = try TokenStorage.shared.loadAccessToken()
            return true
        } catch {
            return false
        }
    }
    
    // 인증 화면 (로그인)
    func showAuth() {
        print("show auth")
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        authCoordinator.start()
        self.authCoordinator = authCoordinator
    }
    
    // 메인 화면 (홈)
    func showMainTabBar() {
        print("🟡 showMainTabBar 호출됨")
        
        let mainTabBarCoordinator = MainTabBarCoordinator(navigationController: navigationController)  // ✅ 주입!
        mainTabBarCoordinator.parentCoordinator = self
        mainTabBarCoordinator.start()
        
        print("🟡 navigationController.setViewControllers 실행")
        navigationController.setViewControllers([mainTabBarCoordinator.tabBarController], animated: true)
        self.mainTabBarCoordinator = mainTabBarCoordinator
        
        print("🟡 showMainTabBar 완료")
    }
    
    // 로그아웃
    func logout() {
        do {
            try TokenStorage.shared.deleteAllTokens()
            print("🔧 [DEBUG] 토큰 삭제됨 - 로그인 화면으로 이동")
            
            // 기존 coordinator 정리 후 인증 화면으로 전환
            mainTabBarCoordinator = nil
            authCoordinator = nil
            showAuth()
            
        } catch {
            print("로그아웃 실패: \(error)")
        }
    }
}
