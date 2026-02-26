//
//  NicknameTransitionViewController.swift
//  Forday
//
//  Created by Subeen on 1/28/26.
//

import UIKit

class NicknameTransitionViewController: UIViewController {

    // Properties

    private let transitionView = NicknameTransitionView()
    weak var coordinator: OnboardingCoordinator?

    // Lifecycle

    override func loadView() {
        view = transitionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        // 네비게이션 바 숨기기 (progress bar 제거)
        navigationController?.setNavigationBarHidden(true, animated: false)

        // 로띠 재생 완료 시 다음 화면으로 전환
        transitionView.onAnimationCompleted = { [weak self] in
            self?.coordinator?.showOnboardingComplete()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 로띠 애니메이션 재생
        transitionView.playAnimation()
    }

}

#Preview {
    let nav = UINavigationController()
    let coordinator = OnboardingCoordinator(navigationController: nav)
    let vc = NicknameTransitionViewController()
    vc.coordinator = coordinator
    nav.pushViewController(vc, animated: false)
    return nav
}
