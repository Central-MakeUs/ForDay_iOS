//
//  AppDelegate.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//

import UIKit
import KakaoSDKCommon
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Firebase 초기화
        FirebaseApp.configure()
        
        // Push 알림 초기화
        PushNotificationService.shared.setup(application: application)

#if DEBUG
//        if ProcessInfo.processInfo.environment["CLEAR_TOKENS_ON_LAUNCH"] == "YES" {
//            try? TokenStorage.shared.deleteAllTokens()
//            print("🔧 [DEBUG] 토큰 삭제됨 - 로그인 화면으로 이동")
//        }

        // 앱 인트로 테스트용 - 주석 해제하면 매 빌드마다 앱 소개 화면 표시
        // AppLaunchStorage.shared.resetAppIntroStatus()
        // print("🔧 [DEBUG] 앱 인트로 상태 리셋됨 - 앱 소개 화면 표시")
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
