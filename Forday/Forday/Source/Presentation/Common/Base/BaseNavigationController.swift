//
//  BaseNavigationController.swift
//  Forday
//
//  Created by Subeen on 2/12/26.
//

import UIKit

/// 중복 push를 방지하는 BaseNavigationController
/// 빠른 연속 탭으로 인한 화면 중복 추가를 막습니다.
class BaseNavigationController: UINavigationController {

    private var isPushingViewController = false

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard !isPushingViewController else { return }
        isPushingViewController = true

        super.pushViewController(viewController, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        isPushingViewController = false
    }
}
