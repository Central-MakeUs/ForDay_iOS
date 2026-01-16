//
//  ActivityWriteViewController.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import Combine

class ActivityWriteViewController: UIViewController {
    
    // Properties
    
    private let writeView = ActivityWriteView()
    private let viewModel = ActivityWriteViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // Coordinator
    weak var coordinator: MainTabBarCoordinator?
    
    // Lifecycle
    
    override func loadView() {
        view = writeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        bind()
    }
}

// Setup

extension ActivityWriteViewController {
    private func setupNavigationBar() {
        title = "내 활동 남기기"
        
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
        // 스티커 선택
        writeView.stickerCollectionView.delegate = self
        writeView.stickerCollectionView.dataSource = self
        
        // 사진 추가
        writeView.photoAddButton.addTarget(
            self,
            action: #selector(photoAddButtonTapped),
            for: .touchUpInside
        )
        
        // 작성완료 버튼
        writeView.submitButton.addTarget(
            self,
            action: #selector(submitButtonTapped),
            for: .touchUpInside
        )
    }
    
    private func bind() {
        // 활동 선택
        viewModel.$selectedActivity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activity in
                self?.writeView.updateActivityTitle(activity?.content)
            }
            .store(in: &cancellables)
        
        // 작성 완료 버튼 활성화
        viewModel.$isSubmitEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.writeView.setSubmitButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)
    }
}

// Actions

extension ActivityWriteViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func photoAddButtonTapped() {
        // TODO: 사진 선택
        print("사진 추가 탭")
    }
    
    @objc private func submitButtonTapped() {
        // TODO: 활동 저장
        print("작성완료 탭")
        dismiss(animated: true)
    }
}

// UICollectionView

extension ActivityWriteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as? StickerCell else {
            return UICollectionViewCell()
        }
        
        let sticker = viewModel.stickers[indexPath.item]
        cell.configure(with: sticker, isSelected: viewModel.selectedSticker == sticker)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sticker = viewModel.stickers[indexPath.item]
        viewModel.selectSticker(sticker)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 64, height: 64)
    }
}

#Preview {
    let nav = UINavigationController()
    let vc = ActivityWriteViewController()
    nav.setViewControllers([vc], animated: false)
    return nav
}
