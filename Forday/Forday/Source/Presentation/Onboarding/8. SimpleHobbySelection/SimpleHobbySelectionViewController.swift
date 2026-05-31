//
//  SimpleHobbySelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//

import UIKit
import Combine

class SimpleHobbySelectionViewController: BaseOnboardingViewController {

    // MARK: - Properties

    private let hobbyView = SimpleHobbySelectionView()
    private let viewModel = SimpleHobbySelectionViewModel()
    var nickname: String?

    // Coordinator
    weak var authCoordinator: AuthCoordinator?

    // MARK: - Lifecycle

    override func loadView() {
        view = hobbyView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("취미 선택")
        setupCollectionView()
        setupActions()
        bind()
        if let nickname {
            hobbyView.updateTitleLabel(nickname: nickname)
        }
        fetchHobbyInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Progress bar 숨기기
        hideProgressBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hobbyView.updateCollectionViewHeight()
    }

    // MARK: - Actions

    override func nextButtonTapped() {
        guard !isTransitioning else { return }
        startTransition()

        // 취미 생성 API 호출
        Task { [weak self] in
            guard let self = self else { return }
            do {
                // v2 API로 취미 생성
                _ = try await self.viewModel.createHobbies()

                // 성공 시 포비 소개 화면으로
                await MainActor.run { [weak self] in
                    self?.authCoordinator?.showPobyIntroduction()
                }
            } catch {
                // 실패 시 에러 처리
                await MainActor.run { [weak self] in
                    self?.resetTransition()
                    self?.showError(error)
                }
            }
        }
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

    override func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Setup

extension SimpleHobbySelectionViewController {
    private func setupCollectionView() {
        hobbyView.collectionView.delegate = self
        hobbyView.collectionView.dataSource = self
    }

    private func setupActions() {
        // 플러스 버튼은 컬렉션뷰의 마지막 아이템으로 처리
    }

    private func bind() {
        viewModel.$selectedHobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hobbyView.collectionView.reloadData()
                self?.updateCollectionViewHeight()
            }
            .store(in: &cancellables)

        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.setNextButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)

        // 취미 목록 업데이트 시 CollectionView 리로드
        viewModel.$hobbyCards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hobbyView.collectionView.reloadData()
                self?.updateCollectionViewHeight()
            }
            .store(in: &cancellables)
    }

    private func updateCollectionViewHeight() {
        // CollectionView 레이아웃 강제 업데이트
        hobbyView.collectionView.layoutIfNeeded()
        // 높이 업데이트
        hobbyView.updateCollectionViewHeight()
    }

    private func fetchHobbyInfo() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.fetchHobbyInfo()
            } catch {
                // 실패 시에도 하드코딩된 빈 리스트로 진행
                print("⚠️ 취미 정보 조회 실패: \(error)")
            }
        }
    }

    private func showCustomInputPopup() {
        guard !isTransitioning else { return }

        let popup = TextInputPopupViewController(title: "취미 입력", placeholder: "취미를 입력해 주세요.")
        popup.onSubmit = { [weak self] hobbyName in
            guard let self else { return }
            self.viewModel.addCustomHobby(hobbyName)
        }
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension SimpleHobbySelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 취미 목록 + 플러스 버튼 (1개)
        return viewModel.hobbies.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HobbyChipCollectionViewCell.identifier,
            for: indexPath
        ) as? HobbyChipCollectionViewCell else {
            return UICollectionViewCell()
        }

        // 마지막 아이템은 플러스 버튼
        if indexPath.item == viewModel.hobbies.count {
            cell.configure(with: "+", isSelected: false)
        } else {
            let hobby = viewModel.hobbies[indexPath.item]
            let isSelected = viewModel.isSelected(hobby)
            cell.configure(with: hobby, isSelected: isSelected)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SimpleHobbySelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 마지막 아이템은 플러스 버튼 → 커스텀 입력 팝업
        if indexPath.item == viewModel.hobbies.count {
            showCustomInputPopup()
        } else {
            let hobby = viewModel.hobbies[indexPath.item]
            viewModel.toggleHobby(hobby)
        }
    }
}

#Preview {
    let nav = UINavigationController()
    let vc = SimpleHobbySelectionViewController()
    nav.setViewControllers([vc], animated: false)
    return nav
}
