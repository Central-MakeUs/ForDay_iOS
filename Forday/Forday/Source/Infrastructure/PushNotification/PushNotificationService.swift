//
//  PushNotificationService.swift
//  Forday
//
//  Created by Subeen on 4/3/26.
//

import UIKit
import UserNotifications
import FirebaseMessaging
import Combine

final class PushNotificationService: NSObject {
    
    static let shared = PushNotificationService()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Setup
    
    func setup(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // 1. 시스템에 알림 권한 요청 (최초 1회 팝업)
        requestPermission { [weak self] authorized in
            if authorized {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // MARK: - Permission Management
    
    /// 시스템 권한 요청
    func requestPermission(completion: @escaping (Bool) -> Void) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error = error {
                print("❌ [Push] Permission request error: \(error)")
                completion(false)
                return
            }
            print("✅ [Push] Permission granted: \(granted)")
            completion(granted)
        }
    }
    
    /// 현재 권한 상태 체크
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
    
    /// 시스템 설정 창으로 이동
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationService: UNUserNotificationCenterDelegate {
    
    // 앱이 포그라운드(사용 중)일 때 알림이 오면 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 앱 사용 중에도 배너 표시
        completionHandler([.banner, .list, .sound])
    }
    
    // 유저가 알림을 '클릭'했을 때 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // 백엔드 명세: data 내의 landingUrl 추출
        if let landingUrl = userInfo["landingUrl"] as? String {
            print("🚀 [Push] Landing URL: \(landingUrl)")
            // AppEventBus를 통해 앱 전체에 알림 클릭 전파
            AppEventBus.shared.pushNotificationReceived.send(landingUrl)
        }
        
        completionHandler()
    }
}

// MARK: - MessagingDelegate

extension PushNotificationService: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("🔥 [Push] FCM Token 발급 완료: \(token)")
        
        // 여기서 FCM 토큰을 저장하거나 필요 시 서버로 갱신 API를 보낼 수 있음
        // (보통 로그온 직후나 토큰 발급 직후에 보냄)
    }
}
