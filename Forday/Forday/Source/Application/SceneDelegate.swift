//
//  SceneDelegate.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//

import UIKit
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        print("🔥 SceneDelegate willConnectTo")
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Window 생성
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .bg001
        self.window = window
        
        // AppCoordinator 시작

        window.makeKeyAndVisible()          // ⭐️ 먼저 Key Window로 만든다

        let appCoordinator = AppCoordinator(window: window)
        self.appCoordinator = appCoordinator
        appCoordinator.start()
    }
    
    // 카카오 로그인 URL 처리
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    // MARK: - Token Expiration

    func showLoginScreen() {
        appCoordinator?.showAuth()
    }
}

