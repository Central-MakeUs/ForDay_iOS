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

        // 1초 후 OnboardingComplete 화면으로 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.coordinator?.showOnboardingComplete()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 다음 화면을 위해 네비게이션 바 다시 보이기
        navigationController?.setNavigationBarHidden(false, animated: false)
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
