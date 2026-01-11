//
//  AppDelegate.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//

import UIKit
import KakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
#if DEBUG
        if ProcessInfo.processInfo.environment["CLEAR_TOKENS_ON_LAUNCH"] == "YES" {
            try? TokenStorage.shared.deleteTokens()
            print("🔧 [DEBUG] 토큰 삭제됨 - 로그인 화면으로 이동")
        }
#endif
        
        // Info.plist에서 카카오 앱 키 읽기
        guard let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String else {
            fatalError("KAKAO_APP_KEY not found in Info.plist")
        }
        
        // 카카오 SDK 초기화
        KakaoSDK.initSDK(appKey: kakaoAppKey)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("🔥 configurationForConnecting called")
        
        let config = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        config.delegateClass = SceneDelegate.self
        return config
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
