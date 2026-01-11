//
//  MainTabBarCoordinator.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import UIKit

class MainTabBarCoordinator: Coordinator {
    
    let navigationController: UINavigationController = UINavigationController()
    let tabBarController: UITabBarController = UITabBarController()
    
    weak var parentCoordinator: AppCoordinator?
    
    func start() {
        setupTabBar()
    }
    
    private func setupTabBar() {
        // 홈 탭
        let homeVC = UIViewController()
        homeVC.view.backgroundColor = .systemBackground
        homeVC.title = "홈"
        homeVC.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // 기록 탭
        let recordVC = UIViewController()
        recordVC.view.backgroundColor = .systemBackground
        recordVC.title = "기록"
        recordVC.tabBarItem = UITabBarItem(
            title: "기록",
            image: UIImage(systemName: "book"),
            selectedImage: UIImage(systemName: "book.fill")
        )
        
        // 프로필 탭
        let profileVC = UIViewController()
        profileVC.view.backgroundColor = .systemBackground
        profileVC.title = "프로필"
        profileVC.tabBarItem = UITabBarItem(
            title: "프로필",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        // TabBar 설정
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: homeVC),
            UINavigationController(rootViewController: recordVC),
            UINavigationController(rootViewController: profileVC)
        ]
        
        tabBarController.tabBar.tintColor = .systemOrange
    }
}