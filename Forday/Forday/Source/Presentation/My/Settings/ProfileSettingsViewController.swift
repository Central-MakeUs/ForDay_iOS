//
//  ProfileSettingsViewController.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit
import Combine
import PhotosUI
import Kingfisher

final class ProfileSettingsViewController: UIViewController {

    // MARK: - Properties

    private var profileSettingsView: ProfileSettingsView {
        return view as! ProfileSettingsView
    }

    private let viewModel: ProfileSettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    weak var coordinator: MainTabBarCoordinator?

    // MARK: - Initialization

    init(viewModel: ProfileSettingsViewModel = ProfileSettingsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = ProfileSettingsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        bind()
        loadUserInfo()

        // Hide navigation bar immediately in viewDidLoad
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

}

// MARK: - Setup

extension ProfileSettingsViewController {
    private func setupActions() {
        // Back button
        profileSettingsView.backButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )

        // Complete button
        profileSettingsView.completeButton.addTarget(
            self,
            action: #selector(completeButtonTapped),
            for: .touchUpInside
        )

        // Profile image tap
        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileSettingsView.profileImageView.addGestureRecognizer(profileTapGesture)

        let cameraTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileSettingsView.cameraIconView.addGestureRecognizer(cameraTapGesture)

        // Nickname text field
        profileSettingsView.nicknameTextField.addTarget(
            self,
            action: #selector(nicknameTextFieldChanged),
            for: .editingChanged
        )

        // Duplicate check button
        profileSettingsView.duplicateCheckButton.addTarget(
            self,
            action: #selector(duplicateCheckButtonTapped),
            for: .touchUpInside
        )

        // Keyboard dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func bind() {
        // Profile Image
        viewModel.$profileImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.profileSettingsView.updateProfileImage(image)
            }
            .store(in: &cancellables)

        // Profile Image URL (for initial load)
        viewModel.$profileImageUrl
            .receive(on: DispatchQueue.main)
            .sink { [weak self] urlString in
                guard let self = self else { return }
                if let urlString = urlString, !urlString.isEmpty, let url = URL(string: urlString) {
                    self.profileSettingsView.profileImageView.kf.setImage(
                        with: url,
                        placeholder: UIImage.Icon.defaultProfile
                    )
                } else {
                    self.profileSettingsView.profileImageView.image = .Icon.defaultProfile
                }
            }
            .store(in: &cancellables)

        // Nickname
        viewModel.$nickname
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                guard let self = self else { return }
                if self.profileSettingsView.nicknameTextField.text != nickname {
                    self.profileSettingsView.nicknameTextField.text = nickname
                }
            }
            .store(in: &cancellables)

        // Validation Result
        viewModel.$validationResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.profileSettingsView.updateValidationState(result)
            }
            .store(in: &cancellables)

        // Complete Button Enabled
        viewModel.$isCompleteButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.profileSettingsView.updateCompleteButtonState(isEnabled: isEnabled)
            }
            .store(in: &cancellables)

        // Error
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }

    private func loadUserInfo() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let usersRepository = UsersRepository()
                let userInfo = try await usersRepository.fetchUserInfo(userId: nil)

                await MainActor.run { [weak self] in
                    self?.viewModel.setInitialProfile(
                        nickname: userInfo.nickname,
                        profileImageUrl: userInfo.profileImageUrl
                    )
                }
            } catch let appError as AppError {
                await MainActor.run { [weak self] in
                    self?.showError(appError)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.showError(.unknown(error))
                }
            }
        }
    }
}

// MARK: - Actions

extension ProfileSettingsViewController {
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func completeButtonTapped() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.saveProfile()

                await MainActor.run { [weak self] in
                    ToastView.show(message: "프로필 수정 완료!")
                    self?.navigationController?.popViewController(animated: true)
                }
            } catch let appError as AppError {
                await MainActor.run { [weak self] in
                    self?.showError(appError)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.showError(.unknown(error))
                }
            }
        }
    }

    @objc private func profileImageTapped() {
        showProfileImageBottomSheet()
    }

    @objc private func nicknameTextFieldChanged() {
        viewModel.nickname = profileSettingsView.nicknameTextField.text ?? ""
    }

    @objc private func duplicateCheckButtonTapped() {
        Task { [weak self] in
            await self?.viewModel.checkDuplicate()
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Bottom Sheet

extension ProfileSettingsViewController {
    private func showProfileImageBottomSheet() {
        let bottomSheetVC = ProfileImageBottomSheetViewController()

        bottomSheetVC.onOptionSelected = { [weak self] option in
            guard let self = self else { return }

            switch option {
            case .selectFromAlbum:
                self.showImagePicker()
            case .setDefaultImage:
                self.resetToDefaultImage()
            }
        }

        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [.custom { _ in 240 }]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 20
        }

        present(bottomSheetVC, animated: true)
    }
}

// MARK: - Image Picker

extension ProfileSettingsViewController {
    private func showImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func resetToDefaultImage() {
        // UI 먼저 업데이트
        profileSettingsView.updateProfileImage(nil)

        Task { [weak self] in
            do {
                let repository = UsersRepository()
                _ = try await repository.updateProfileImage(profileImageUrl: nil)

                await MainActor.run {
                    ToastView.show(message: "기본 이미지로 변경되었습니다.")
                }
            } catch let appError as AppError {
                await MainActor.run { [weak self] in
                    self?.showError(appError)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.showError(.unknown(error))
                }
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ProfileSettingsViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.uploadProfileImage(image)
                }
            }
        }
    }

    private func uploadProfileImage(_ image: UIImage) {
        // UI 먼저 업데이트
        profileSettingsView.updateProfileImage(image)

        Task { [weak self] in
            do {
                let useCase = UpdateProfileImageUseCase()
                _ = try await useCase.execute(image: image)

                await MainActor.run {
                    ToastView.show(message: "프로필 사진이 변경되었습니다.")
                }
            } catch let appError as AppError {
                await MainActor.run { [weak self] in
                    // 실패 시 원래 이미지로 복구
                    self?.profileSettingsView.updateProfileImage(nil)
                    self?.showError(appError)
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.profileSettingsView.updateProfileImage(nil)
                    self?.showError(.unknown(error))
                }
            }
        }
    }
}

// MARK: - Error Handling

extension ProfileSettingsViewController {
    private func showError(_ error: AppError) {
        ToastView.showError(message: error.userMessage)
    }
}

#if DEBUG
#Preview {
    ProfileSettingsViewController()
}
#endif
