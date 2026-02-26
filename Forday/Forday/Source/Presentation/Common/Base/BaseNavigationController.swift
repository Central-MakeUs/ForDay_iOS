//
//  BaseNavigationController.swift
//  Forday
//
//  Created by Subeen on 2/12/26.
//

import UIKit

/// 중복 push를 방지하는 BaseNavigationController
/// 빠른 연속 탭으로 인한 화면 중복 추가를 막습니다.
/// 네비게이션 바가 숨겨져 있어도 스와이프 백 제스처를 지원합니다.
class BaseNavigationController: UINavigationController {

    private var isPushingViewController = false

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }

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

// MARK: - UINavigationControllerDelegate

extension BaseNavigationController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        // 화면 전환 완료 후 스와이프 백 제스처 재활성화
        interactivePopGestureRecognizer?.isEnabled = viewControllers.count > 1
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Root ViewController가 아닐 때만 스와이프 백 제스처 허용
        return viewControllers.count > 1
    }
}
