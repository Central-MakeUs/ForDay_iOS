//
//  HobbyActivityInputViewController.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import UIKit
import Combine

class HobbyActivityInputViewController: UIViewController {
    
    // Properties
    
    private let activityInputView = HobbyActivityInputView()
    private let viewModel: HobbyActivityInputViewModel
    private let hobbyId: Int
    private var cancellables = Set<AnyCancellable>()
    
    // Callbacks
    var onActivityCreated: (() -> Void)?
    
    // Initialization
    
    init(hobbyId: Int, viewModel: HobbyActivityInputViewModel = HobbyActivityInputViewModel()) {
        self.hobbyId = hobbyId
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func loadView() {
        view = activityInputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        bind()
    }
}

// Setup

extension HobbyActivityInputViewController {
    private func setupNavigationBar() {
        title = "취미활동 입력"
        
        // X 버튼
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .label
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setupActions() {
        activityInputView.onSaveButtonTapped = { [weak self] in
            self?.saveActivities()
        }
        
        activityInputView.onAddButtonTapped = { [weak self] in
            self?.addActivityField()
        }
        
        activityInputView.onDeleteButtonTapped = { [weak self] index in
            self?.deleteActivityField(at: index)
        }
    }
    
    private func bind() {
        // 저장 버튼 활성화 상태
        viewModel.$isSaveButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.activityInputView.setSaveButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)
        
        // 로딩 상태
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: 로딩 인디케이터
                print(isLoading ? "저장 중..." : "저장 완료")
            }
            .store(in: &cancellables)
    }
}

// Actions

extension HobbyActivityInputViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func addActivityField() {
        activityInputView.addActivityField()
        validateActivities()
    }
    
    private func deleteActivityField(at index: Int) {
        activityInputView.deleteActivityField(at: index)
        validateActivities()
    }
    
    private func validateActivities() {
        let activities = activityInputView.getActivities()
        viewModel.updateActivities(activities)
    }
    
    private func saveActivities() {
        let activities = activityInputView.getActivities()
        
        Task {
            do {
                try await viewModel.createActivities(hobbyId: hobbyId, activities: activities)
                
                await MainActor.run {
                    onActivityCreated?()
                    dismiss(animated: true)
                }
            } catch {
                await MainActor.run {
                    showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

#Preview {
    let inputVC = HobbyActivityInputViewController(hobbyId: 1)
    let nav = UINavigationController(rootViewController: inputVC)
    return nav
}
