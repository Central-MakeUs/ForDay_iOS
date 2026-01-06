//
//  AppDelegate.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var onboardingCoordinator: OnboardingCoordinator?  // Coordinator 보관
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        
        // 온보딩 시작
        let navigationController = UINavigationController()
        onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator?.start()
        
        window?.rootViewController = navigationController
        
        return true
    }
}
