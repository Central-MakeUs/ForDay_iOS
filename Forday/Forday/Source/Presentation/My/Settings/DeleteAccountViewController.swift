//
//  DeleteAccountViewController.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit

final class DeleteAccountViewController: UIViewController {

    // MARK: - Properties

    private var deleteAccountView: DeleteAccountView {
        return view as! DeleteAccountView
    }

    private let authService = AuthService()

    weak var coordinator: MainTabBarCoordinator?

    // MARK: - Lifecycle

    override func loadView() {
        view = DeleteAccountView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }

}

// MARK: - Setup

extension DeleteAccountViewController {
    private func setupActions() {
        // Back button
        deleteAccountView.backButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )

        // Checkbox button
        deleteAccountView.checkboxButton.addTarget(
            self,
            action: #selector(checkboxTapped),
            for: .touchUpInside
        )

        // Delete button
        deleteAccountView.deleteButton.addTarget(
            self,
            action: #selector(deleteButtonTapped),
            for: .touchUpInside
        )
    }
}

// MARK: - Actions

extension DeleteAccountViewController {
    @objc private func backButtonTapped() {
        // Pop if in navigation stack, otherwise dismiss
        if let navController = navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func checkboxTapped() {
        deleteAccountView.isChecked.toggle()
    }

    @objc private func deleteButtonTapped() {
        performDeleteAccount()
    }

    private func performDeleteAccount() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let response = try await self.authService.withdraw()

                // Delete local tokens
                try? TokenStorage.shared.deleteAllTokens()

                // Delete onboarding data
                try? OnboardingDataStorage.shared.delete()

                print("✅ Account deleted successfully")

                await MainActor.run { [weak self] in
                    self?.showSuccessPopup(message: response.data.message)
                }

            } catch {
                print("❌ Delete account failed: \(error)")
                await MainActor.run { [weak self] in
                    self?.showErrorPopup(message: "탈퇴 처리 중 오류가 발생했습니다.")
                }
            }
        }
    }

    private func showSuccessPopup(message: String) {
        let popup = CommonPopupViewController(
            title: message,
            message: "",
            primaryButtonTitle: "확인"
        )

        popup.onPrimaryAction = { [weak self] in
            self?.navigateToLogin()
        }

        present(popup, animated: true)
    }

    private func showErrorPopup(message: String) {
        ToastView.showError(message: message)
    }

    private func navigateToLogin() {
        // Dismiss the entire navigation controller (GeneralSettings modal)
        navigationController?.dismiss(animated: false) { [weak self] in
            self?.coordinator?.parentCoordinator?.logout()
        }
    }
}

#if DEBUG
#Preview {
    DeleteAccountViewController()
}
#endif
