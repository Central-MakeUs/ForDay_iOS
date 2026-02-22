//
//  ManageHobbyCoverViewController.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import Combine
import PhotosUI

class ManageHobbyCoverViewController: UIViewController {

    // MARK: - Properties

    private let manageCoverView = ManageHobbyCoverView()
    private let viewModel: ManageHobbyCoverViewModel
    private var cancellables = Set<AnyCancellable>()

    private var pendingGalleryHobbyId: Int?

    // MARK: - Initialization

    init(viewModel: ManageHobbyCoverViewModel = ManageHobbyCoverViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = manageCoverView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavigation()
        setupCollectionViews()
        bind()
        loadInitialData()

        // Hide navigation bar immediately in viewDidLoad
        navigationController?.setNavigationBarHidden(true, animated: false)
    }


    // MARK: - Setup

    private func setupCustomNavigation() {
        // Back button callback
        manageCoverView.onBackButtonTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        // Done button action
        manageCoverView.doneButton.addTarget(
            self,
            action: #selector(doneButtonTapped),
            for: .touchUpInside
        )
    }

    private func setupCollectionViews() {
        // Hobby Collection View
        manageCoverView.hobbyCollectionView.dataSource = self
        manageCoverView.hobbyCollectionView.delegate = self

        // Feed Collection View
        manageCoverView.feedCollectionView.dataSource = self
        manageCoverView.feedCollectionView.delegate = self
    }

    private func bind() {
        // Hobbies
        viewModel.$hobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.manageCoverView.hobbyCollectionView.reloadData()
            }
            .store(in: &cancellables)

        // Feed Items
        viewModel.$feedItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.manageCoverView.updateFeedCount(items.count)
                self?.manageCoverView.showEmptyState(items.isEmpty)
                self?.manageCoverView.feedCollectionView.reloadData()
            }
            .store(in: &cancellables)

        // Selection Mode
        viewModel.$isSelectionMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSelectionMode in
                self?.manageCoverView.setDoneButtonHidden(!isSelectionMode)
                self?.manageCoverView.feedCollectionView.reloadData()
            }
            .store(in: &cancellables)

        // Selected Record
        viewModel.$selectedRecordId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedId in
                self?.manageCoverView.setDoneButtonEnabled(selectedId != nil)
                self?.manageCoverView.feedCollectionView.reloadData()
            }
            .store(in: &cancellables)

        // Error Handling
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleAppError(error)
            }
            .store(in: &cancellables)
    }

    private func loadInitialData() {
        Task {
            await viewModel.fetchAllFeeds()
        }
    }

    // MARK: - Actions

    @objc private func doneButtonTapped() {
        Task {
            do {
                let message = try await viewModel.updateCoverImageWithRecord()

                await MainActor.run {
                    ToastView.show(message: message)
                    self.navigationController?.popViewController(animated: true)
                }
            } catch let appError as AppError {
                await MainActor.run {
                    self.handleAppError(appError)
                }
            } catch {
                await MainActor.run {
                    self.handleAppError(.unknown(error))
                }
            }
        }
    }

    // MARK: - Hobby Camera Icon Tapped

    private func showCoverImageOptions(for hobby: MyPageHobby) {
        CoverImageOptionSheet.present(
            on: self,
            hobbyName: hobby.hobbyName,
            onGallerySelected: { [weak self] in
                self?.handleGallerySelection(for: hobby)
            },
            onActivitySelected: { [weak self] in
                self?.handleActivitySelection(for: hobby)
            }
        )
    }

    private func handleGallerySelection(for hobby: MyPageHobby) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        pendingGalleryHobbyId = hobby.hobbyId
        present(picker, animated: true)

        // Store selected hobby for later use
        // TODO: Better way to pass hobby to PHPicker delegate
    }

    private func handleActivitySelection(for hobby: MyPageHobby) {
        // Enter selection mode
        viewModel.enterSelectionMode(forHobbyId: hobby.hobbyId)
    }
}

// MARK: - UICollectionViewDataSource (Hobby)

extension ManageHobbyCoverViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == manageCoverView.hobbyCollectionView {
            return viewModel.hobbies.count
        } else {
            return viewModel.feedItems.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == manageCoverView.hobbyCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HobbyCoverCell",
                for: indexPath
            ) as? HobbyCoverCell else {
                return UICollectionViewCell()
            }

            let hobby = viewModel.hobbies[indexPath.item]
            cell.configure(hobby: hobby)
            return cell

        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "FeedItemCell",
                for: indexPath
            ) as? FeedItemCell else {
                return UICollectionViewCell()
            }

            let feedItem = viewModel.feedItems[indexPath.item]
            let isSelected = viewModel.selectedRecordId == feedItem.recordId
            cell.configure(
                feedItem: feedItem,
                isSelectionMode: viewModel.isSelectionMode,
                isSelected: isSelected
            )
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ManageHobbyCoverViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == manageCoverView.hobbyCollectionView {
            let hobby = viewModel.hobbies[indexPath.item]

            // 카메라 아이콘 클릭으로 간주 → 바텀시트
            showCoverImageOptions(for: hobby)

        } else {
            // Feed 선택 (선택 모드일 때만)
            guard viewModel.isSelectionMode else { return }

            let feedItem = viewModel.feedItems[indexPath.item]
            viewModel.toggleFeedItemSelection(feedItem.recordId)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ManageHobbyCoverViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == manageCoverView.hobbyCollectionView {
            // HobbyFilterView와 동일: 48pt width, 66pt height
            return CGSize(width: 48, height: 66)
        } else {
            // Feed grid: 셀간 간격 1을 제외한 너비 삼등분
            let numberOfColumns: CGFloat = 3
            let spacing: CGFloat = 1
            let totalSpacing = spacing * (numberOfColumns - 1)
            let availableWidth = collectionView.bounds.width - totalSpacing
            let itemWidth = floor(availableWidth / numberOfColumns)

            // 피그마 셀 비율: 106:128 (width:height)
            let itemHeight = floor(itemWidth * 128 / 106)

            return CGSize(width: itemWidth, height: itemHeight)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        if collectionView == manageCoverView.feedCollectionView {
            return .zero
        }
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView == manageCoverView.feedCollectionView {
            return 1
        }
        return 16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView == manageCoverView.feedCollectionView {
            return 1
        }
        return 16
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ManageHobbyCoverViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else {
            // User cancelled - clear pending state
            pendingGalleryHobbyId = nil
            return
        }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self, let image = object as? UIImage else {
                Task { @MainActor in
                    self?.pendingGalleryHobbyId = nil
                }
                return
            }
            guard let hobbyId = self.pendingGalleryHobbyId else { return }
            
            Task {
                do {
                    let message = try await self.viewModel.updateCoverImageWithGallery(hobbyId: hobbyId, image: image)
                    await MainActor.run {
                        // Clear pending state
                        self.pendingGalleryHobbyId = nil

                        ToastView.show(message: message)
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch let appError as AppError {
                    await MainActor.run {
                        self.pendingGalleryHobbyId = nil
                        self.handleAppError(appError)
                    }
                } catch {
                    await MainActor.run {
                        self.pendingGalleryHobbyId = nil
                        self.handleAppError(.unknown(error))
                    }
                }
            }
        }
    }
}
