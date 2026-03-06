//
//  ReportViewController.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class ReportViewController: UIViewController {

    // MARK: - Properties

    private var reportView: ReportView {
        return view as! ReportView
    }

    private let recordId: Int?
    private let targetUserId: String
    private let targetNickname: String

    private var selectedReason: ReportReasonType?
    private var cancellables = Set<AnyCancellable>()

    var onReportCompleted: ((Bool) -> Void)?  // Bool indicates if user also blocked

    // MARK: - Initialization

    /// 활동 기록 신고용 초기화
    init(recordId: Int, authorUserId: String, authorNickname: String) {
        self.recordId = recordId
        self.targetUserId = authorUserId
        self.targetNickname = authorNickname
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    /// 사용자 신고용 초기화 (활동 기록 없이 사용자만 신고)
    init(targetUserId: String, targetNickname: String) {
        self.recordId = nil
        self.targetUserId = targetUserId
        self.targetNickname = targetNickname
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = ReportView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Setup

extension ReportViewController {
    private func setupCollectionView() {
        reportView.collectionView.delegate = self
        reportView.collectionView.dataSource = self
    }

    private func setupActions() {
        reportView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        reportView.submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Actions

extension ReportViewController {
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func submitButtonTapped() {
        guard let reason = selectedReason else { return }

        // Show block user confirmation bottom sheet
        showBlockUserConfirmation(reason: reason)
    }

    private func showBlockUserConfirmation(reason: ReportReasonType) {
        let bottomSheet = BlockUserBottomSheetViewController(
            nickname: targetNickname,
            onConfirm: { [weak self] shouldBlock in
                self?.submitReport(reason: reason, shouldBlock: shouldBlock)
            }
        )
        bottomSheet.modalPresentationStyle = .pageSheet

        if let sheet = bottomSheet.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 280 })]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(bottomSheet, animated: true)
    }

    private func submitReport(reason: ReportReasonType, shouldBlock: Bool) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let friendsService = FriendsService()

                // Submit report for record (if recordId exists)
                if let recordId = self.recordId {
                    let recordsService = RecordsService()
                    _ = try await recordsService.reportRecord(recordId: recordId, reason: reason)
                } else {
                    // Submit user report (if recordId doesn't exist)
                    _ = try await friendsService.reportUser(userId: self.targetUserId, reason: reason.rawValue)
                }

                // Block user if requested
                if shouldBlock {
                    _ = try await friendsService.blockUser(userId: self.targetUserId)
                }

                await MainActor.run { [weak self] in
                    if self?.recordId != nil {
                        // 활동 기록 신고
                        ToastView.showSuccess(message: "신고가 접수되었습니다.")
                    } else if shouldBlock {
                        // 사용자 신고 (차단 선택한 경우)
                        ToastView.showSuccess(message: "차단이 완료되었습니다.")
                    } else {
                        // 사용자 신고 (차단 선택 안 한 경우)
                        ToastView.showSuccess(message: "신고가 접수되었습니다.")
                    }

                    self?.navigationController?.popViewController(animated: true)
                    self?.onReportCompleted?(shouldBlock)
                }
            } catch {
                await MainActor.run {
                    if let appError = error as? AppError {
                        ToastView.showError(message: appError.userMessage)
                    } else {
                        ToastView.showError(message: "처리 중 오류가 발생했습니다.")
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ReportViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ReportReasonType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ReportReasonCell.identifier,
            for: indexPath
        ) as? ReportReasonCell else {
            return UICollectionViewCell()
        }

        let reason = ReportReasonType.allCases[indexPath.item]
        let isSelected = reason == selectedReason
        cell.configure(with: reason, isSelected: isSelected)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ReportViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedReason = ReportReasonType.allCases[indexPath.item]
        reportView.updateSubmitButtonState(isEnabled: true)
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ReportViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 52)
    }
}

#if DEBUG
#Preview("ReportViewController") {
    let vc = ReportViewController(recordId: 1, authorUserId: "test-user-id", authorNickname: "테스트닉네임")
    return UINavigationController(rootViewController: vc)
}
#endif
