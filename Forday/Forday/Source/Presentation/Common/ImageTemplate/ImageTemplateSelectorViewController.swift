//
//  ImageTemplateSelectorViewController.swift
//  Forday
//
//  Created by Subeen on 2/24/26.
//

import UIKit
import Combine
import Photos

final class ImageTemplateSelectorViewController: UIViewController {

    // MARK: - Properties

    private let selectorView = ImageTemplateSelectorView()
    private let viewModel: ImageTemplateSelectorViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: ImageTemplateSelectorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = selectorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        bind()
        viewModel.loadImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Setup

extension ImageTemplateSelectorViewController {
    private func setupActions() {
        selectorView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        selectorView.downloadButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        selectorView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    private func bind() {
        // Bind template data
        viewModel.$templateImage
            .combineLatest(viewModel.$activityDetail)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image, detail in
                guard let self = self,
                      let image = image,
                      let detail = detail,
                      let stickerType = StickerType(fileName: detail.sticker) else { return }

                self.selectorView.configureTemplate(
                    image: image,
                    title: detail.activityContent,
                    memo: detail.memo,
                    date: detail.createdAt,
                    stickerType: stickerType
                )
            }
            .store(in: &cancellables)

        // Bind loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoadingIndicator()
                } else {
                    self?.hideLoadingIndicator()
                }
            }
            .store(in: &cancellables)

        // Bind save result
        viewModel.$saveResult
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.showSuccessToast()
                case .failure(let error):
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Actions

extension ImageTemplateSelectorViewController {
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func saveButtonTapped() {
        guard let renderedImage = selectorView.renderCurrentTemplate() else {
            ToastView.showError(message: "이미지 생성에 실패했습니다.")
            return
        }

        viewModel.saveToGallery(image: renderedImage)
    }
}

// MARK: - UI Helpers

extension ImageTemplateSelectorViewController {
    private func showLoadingIndicator() {
        // TODO: Implement loading indicator
    }

    private func hideLoadingIndicator() {
        // TODO: Hide loading indicator
    }

    private func showSuccessToast() {
        // 버튼 위에 토스트 표시 (버튼 높이 ~56 + 버튼 하단 여백 16 + 토스트 여백 16 = 88)
        ToastView.show(
            message: "활동기록 사진 저장완료!",
            icon: .success,
            position: .aboveButton(bottomInset: 88)
        )
    }

    private func showError(_ error: Error) {
        if let appError = error as? AppError {
            ToastView.showError(message: appError.userMessage)
        } else {
            ToastView.showError(message: error.localizedDescription)
        }
    }
}
