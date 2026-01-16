//
//  ActivityListViewController.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import UIKit
import Combine

class ActivityListViewController: UIViewController {
    
    // Properties
    
    private let listView = ActivityListView()
    private let viewModel: ActivityListViewModel
    private let hobbyId: Int
    private var cancellables = Set<AnyCancellable>()
    
    // Coordinator
    weak var coordinator: MainTabBarCoordinator?
    
    // Initialization
    
    init(hobbyId: Int, viewModel: ActivityListViewModel = ActivityListViewModel()) {
        self.hobbyId = hobbyId
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func loadView() {
        view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        bind()
        loadActivities()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // HomeViewController로 돌아갈 때 네비게이션 바 숨기기
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }
}

// Setup

extension ActivityListViewController {
    private func setupNavigationBar() {
        title = "활동 리스트"
        
        // + 버튼
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = .label
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupTableView() {
        listView.tableView.delegate = self
        listView.tableView.dataSource = self
    }
    
    private func bind() {
        // 활동 목록 업데이트
        viewModel.$activities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.listView.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)
        
        // 로딩 상태
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: 로딩 인디케이터
                print(isLoading ? "로딩 중..." : "로딩 완료")
            }
            .store(in: &cancellables)
        
        // 에러 메시지
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func loadActivities() {
        Task {
            await viewModel.fetchActivities(hobbyId: hobbyId)
        }
    }
    
    private func updateEmptyState() {
        listView.setEmptyState(viewModel.activities.isEmpty)
    }
}

// Actions

extension ActivityListViewController {
    @objc private func addButtonTapped() {
        let inputVC = HobbyActivityInputViewController(hobbyId: hobbyId)
        inputVC.onActivityCreated = { [weak self] in
            self?.loadActivities()  // 목록 새로고침
        }
        
        let nav = UINavigationController(rootViewController: inputVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    private func showEditAlert(for activity: Activity) {
        let alert = UIAlertController(
            title: "활동 수정",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = activity.content
            textField.placeholder = "활동 내용"
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "수정", style: .default) { [weak self] _ in
            guard let content = alert.textFields?.first?.text, !content.isEmpty else { return }
            self?.updateActivity(activityId: activity.activityId, content: content)
        })
        
        present(alert, animated: true)
    }
    
    private func showDeleteAlert(for activity: Activity) {
        let alert = UIAlertController(
            title: "활동 삭제",
            message: "정말 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deleteActivity(activityId: activity.activityId)
        })
        
        present(alert, animated: true)
    }
    
    private func updateActivity(activityId: Int, content: String) {
        Task {
            do {
                try await viewModel.updateActivity(activityId: activityId, content: content)
                await viewModel.fetchActivities(hobbyId: hobbyId)  // 새로고침
            } catch {
                await MainActor.run {
                    showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func deleteActivity(activityId: Int) {
        Task {
            do {
                try await viewModel.deleteActivity(activityId: activityId)
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

// UITableViewDataSource

extension ActivityListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCardCell.identifier, for: indexPath) as? ActivityCardCell else {
            return UITableViewCell()
        }
        
        let activity = viewModel.activities[indexPath.row]
        cell.configure(with: activity)
        
        cell.onEditTapped = { [weak self] in
            self?.showEditAlert(for: activity)
        }
        
        cell.onDeleteTapped = { [weak self] in
            self?.showDeleteAlert(for: activity)
        }
        
        return cell
    }
}

// UITableViewDelegate

extension ActivityListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

#Preview {
    let listVC = ActivityListViewController(hobbyId: 1)
    let nav = UINavigationController(rootViewController: listVC)
    return nav
}
