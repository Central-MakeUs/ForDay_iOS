//
//  GuestLoginBottomSheetViewController.swift
//  Forday
//
//  Created by Subeen on 2/4/26.
//

import UIKit
import Combine

protocol GuestLoginBottomSheetDelegate: AnyObject {
    func guestLoginBottomSheetDidLoginSuccess(_ controller: GuestLoginBottomSheetViewController, authToken: AuthToken)
    func guestLoginBottomSheetDidDismiss(_ controller: GuestLoginBottomSheetViewController)
}

final class GuestLoginBottomSheetViewController: UIViewController {

    // MARK: - Properties

    private let bottomSheetView = GuestLoginBottomSheetView()
    private var cancellables = Set<AnyCancellable>()

    // UseCase
    private let switchToKakaoUseCase: SwitchToKakaoUseCase
    private let switchToAppleUseCase: SwitchToAppleUseCase

    // Delegate
    weak var delegate: GuestLoginBottomSheetDelegate?

    // 로그인 성공 여부 (dismiss 시 홈 이동 여부 결정)
    private var didLoginSuccessfully = false

    // MARK: - Initialization

    init(useCaseFactory: AuthUseCaseFactory = AuthUseCaseFactory()) {
        self.switchToKakaoUseCase = useCaseFactory.makeSwitchToKakaoUseCase()
        self.switchToAppleUseCase = useCaseFactory.makeSwitchToAppleUseCase()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = bottomSheetView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // 로그인 성공 없이 바텀시트가 닫힌 경우 (드래그로 닫기)
        if !didLoginSuccessfully {
            delegate?.guestLoginBottomSheetDidDismiss(self)
        }
    }
}

// MARK: - Setup

extension GuestLoginBottomSheetViewController {
    private func setupActions() {
        bottomSheetView.kakaoLoginButton.addTarget(
            self,
            action: #selector(kakaoLoginButtonTapped),
            for: .touchUpInside
        )

        bottomSheetView.appleLoginButton.addTarget(
            self,
            action: #selector(appleLoginButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Actions

    @objc private func kakaoLoginButtonTapped() {
        isModalInPresentation = true // 로그인 중 드래그 dismiss 차단

        Task {
            defer {
                Task { @MainActor in
                    self.isModalInPresentation = false
                }
            }

            do {
                let authToken = try await switchToKakaoUseCase.execute()
                await MainActor.run {
                    didLoginSuccessfully = true
                    dismiss(animated: true) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.guestLoginBottomSheetDidLoginSuccess(self, authToken: authToken)
                    }
                }
            } catch {
                // 사용자 취소 시 에러 알림 표시하지 않음
                if isUserCancellationError(error) { return }
                await MainActor.run {
                    showError(error)
                }
            }
        }
    }

    @objc private func appleLoginButtonTapped() {
        isModalInPresentation = true // 로그인 중 드래그 dismiss 차단

        Task {
            defer {
                Task { @MainActor in
                    self.isModalInPresentation = false
                }
            }

            do {
                let authToken = try await switchToAppleUseCase.execute()
                await MainActor.run {
                    didLoginSuccessfully = true
                    dismiss(animated: true) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.guestLoginBottomSheetDidLoginSuccess(self, authToken: authToken)
                    }
                }
            } catch {
                // 사용자 취소 시 에러 알림 표시하지 않음
                if isUserCancellationError(error) { return }
                await MainActor.run {
                    showError(error)
                }
            }
        }
    }

    // MARK: - Helper

    private func isUserCancellationError(_ error: Error) -> Bool {
        // Apple 로그인 취소
        if let appleError = error as? AppleAuthService.AppleAuthError,
           case .userCancelled = appleError {
            return true
        }
        // Kakao 로그인 취소
        if let kakaoError = error as? KakaoAuthService.KakaoAuthError,
           case .userCancelled = kakaoError {
            return true
        }
        return false
    }

    private func showError(_ error: Error) {
        let message: String
        if let appError = error as? AppError {
            message = appError.userMessage
        } else {
            message = error.localizedDescription
        }
        ToastView.showError(message: message)
    }
}

// MARK: - Presentation Helper

extension GuestLoginBottomSheetViewController {
    /// 바텀 시트로 표시 (화면 2/3 높이)
    static func present(from viewController: UIViewController, delegate: GuestLoginBottomSheetDelegate?) {
        let bottomSheetVC = GuestLoginBottomSheetViewController()
        bottomSheetVC.delegate = delegate
        bottomSheetVC.modalPresentationStyle = .pageSheet

        if let sheet = bottomSheetVC.sheetPresentationController {
            // 화면의 2/3 높이로 설정
            let customDetent = UISheetPresentationController.Detent.custom { context in
                return context.maximumDetentValue * 0.66
            }
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        viewController.present(bottomSheetVC, animated: true)
    }
}

#if DEBUG
#Preview {
    GuestLoginBottomSheetViewController()
}
#endif
