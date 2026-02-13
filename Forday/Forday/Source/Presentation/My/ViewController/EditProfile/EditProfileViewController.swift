//
//  EditProfileViewController.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import Combine
import PhotosUI

class EditProfileViewController: UIViewController {

    // MARK: - Properties

    private let editProfileView = EditProfileView()
    private let viewModel: EditProfileViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var saveButton = UIBarButtonItem(
        title: "완료",
        style: .done,
        target: self,
        action: #selector(saveButtonTapped)
    )

    // MARK: - Initialization

    init(viewModel: EditProfileViewModel = EditProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = editProfileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        bind()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "프로필 설정"
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
    }

    private func setupActions() {
        // Profile Image Tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        editProfileView.profileImageView.addGestureRecognizer(tapGesture)

        // Nickname TextField
        editProfileView.nicknameTextField.addTarget(
            self,
            action: #selector(nicknameTextFieldChanged),
            for: .editingChanged
        )

        // Duplicate Check Button
        editProfileView.duplicateCheckButton.addTarget(
            self,
            action: #selector(duplicateCheckButtonTapped),
            for: .touchUpInside
        )
    }

    private func bind() {
        // Profile Image
        viewModel.$profileImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.editProfileView.updateProfileImage(image)
            }
            .store(in: &cancellables)

        // Nickname
        viewModel.$nickname
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                guard let self = self else { return }
                if self.editProfileView.nicknameTextField.text != nickname {
                    self.editProfileView.nicknameTextField.text = nickname
                }
            }
            .store(in: &cancellables)

        // Validation Result
        viewModel.$validationResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.editProfileView.showValidationMessage(result.message, isError: result != .valid)
            }
            .store(in: &cancellables)

        // Save Button Enabled
        viewModel.$isSaveButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.saveButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)

        // Error Handling
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func profileImageTapped() {
        showImagePicker()
    }

    @objc private func nicknameTextFieldChanged() {
        viewModel.nickname = editProfileView.nicknameTextField.text ?? ""
    }

    @objc private func duplicateCheckButtonTapped() {
        Task {
            await viewModel.checkDuplicate()
        }
    }

    @objc private func saveButtonTapped() {
        Task {
            do {
                try await viewModel.saveProfile()

                await MainActor.run {
                    ToastView.show(message: "프로필 수정 완료!")
                    self.navigationController?.popViewController(animated: true)
                }
            } catch let appError as AppError {
                await MainActor.run {
                    self.handleError(appError)
                }
            } catch {
                await MainActor.run {
                    self.handleError(.unknown(error))
                }
            }
        }
    }

    // MARK: - Image Picker

    private func showImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Error Handling

    private func handleError(_ error: AppError) {
        let alert = UIAlertController(
            title: "오류",
            message: error.userMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.viewModel.updateProfileImage(image)
                }
            }
        }
    }
}
