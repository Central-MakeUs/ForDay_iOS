//
//  NotificationCell.swift
//  Forday
//
//  Created by Subeen on 4/5/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

protocol NotificationCellDelegate: AnyObject {
    func notificationCellDidTap(_ cell: NotificationCell, notification: NotificationItem)
}

final class NotificationCell: UITableViewCell {

    // MARK: - Properties

    static let identifier = "NotificationCell"

    weak var delegate: NotificationCellDelegate?
    private var notification: NotificationItem?

    // MARK: - UI Components

    private let containerView = UIView()
    private let profileImageView = UIImageView()
    private let reactionIconView = UIImageView()
    private let timeLabel = UILabel()
    private let messageLabel = UILabel()
    private let thumbnailImageView = UIImageView()
    private let separatorView = UIView()

    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let verticalInset: CGFloat = 12
        static let profileSize: CGFloat = 36
        static let reactionIconSize: CGFloat = 16
        static let thumbnailSize: CGFloat = 48
        static let textHorizontalSpacing: CGFloat = 8
        static let textVerticalSpacing: CGFloat = 4
    }

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStyle()
        setupLayout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupStyle() {
        selectionStyle = .none
        backgroundColor = .clear

        // contentView에 배경색 적용 (전체 너비)
        contentView.backgroundColor = .clear

        containerView.do {
            $0.backgroundColor = .clear
        }

        profileImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true  // 원형으로 자르기
            $0.layer.cornerRadius = 18  // 36 / 2 = 원형
            $0.backgroundColor = .neutral100
        }

        reactionIconView.do {
            $0.contentMode = .scaleAspectFit
        }

        timeLabel.do {
            $0.applyTypography(.label12)
            $0.textColor = .neutral400
            $0.numberOfLines = 1
        }

        messageLabel.do {
            $0.applyTypography(.label14)
            $0.textColor = .neutral800
            $0.numberOfLines = 0
        }

        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.backgroundColor = .neutral100
        }

        separatorView.do {
            $0.backgroundColor = .neutral100
        }
    }

    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(reactionIconView)  // containerView의 직접 서브뷰로 변경
        containerView.addSubview(timeLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(thumbnailImageView)
        contentView.addSubview(separatorView)  // contentView의 직접 서브뷰로 변경

        // containerView는 전체 너비, 내부 컨텐츠만 패딩
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 원형 프로필 (왼쪽, 20pt 패딩)
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(Layout.profileSize)
        }

        // 감정 아이콘 (프로필 오른쪽 하단에 오버레이)
        reactionIconView.snp.makeConstraints {
            $0.trailing.equalTo(profileImageView.snp.trailing).offset(4)
            $0.bottom.equalTo(profileImageView.snp.bottom).offset(-2)
            $0.size.equalTo(Layout.reactionIconSize)
        }

        // 텍스트 컨테이너 (시간 + 메시지)
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(Layout.textHorizontalSpacing)
            $0.trailing.equalTo(thumbnailImageView.snp.leading).offset(-Layout.textHorizontalSpacing)
            $0.top.equalToSuperview().offset(Layout.verticalInset)
        }

        messageLabel.snp.makeConstraints {
            $0.leading.equalTo(timeLabel)
            $0.trailing.equalTo(timeLabel)
            $0.top.equalTo(timeLabel.snp.bottom).offset(Layout.textVerticalSpacing)
            $0.bottom.equalToSuperview().offset(-Layout.verticalInset)
        }

        // 활동 사진 (오른쪽, 20pt 패딩)
        thumbnailImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Layout.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(Layout.thumbnailSize)
        }

        // 구분선 (전체 너비)
        separatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(-20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        containerView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Configuration

    func configure(with notification: NotificationItem) {
        self.notification = notification

        // 프로필 이미지
        if let profileUrl = notification.senderProfileUrl {
            profileImageView.setImage(with: profileUrl)
        } else {
            profileImageView.image = .Icon.defaultProfile
        }

        // 시간 (빈 문자열이 아닐 때만 표시)
        if !notification.createdAt.isEmpty {
            timeLabel.setTextWithTypography(notification.createdAt, style: .label12)
            timeLabel.isHidden = false
        } else {
            timeLabel.attributedText = nil
            timeLabel.isHidden = true
        }

        // 메시지
        messageLabel.setTextWithTypography(notification.message, style: .label14)

        // 활동 사진
        if let imageUrl = notification.imageUrl {
            thumbnailImageView.isHidden = false
            thumbnailImageView.setImage(with: imageUrl)
        } else {
            thumbnailImageView.isHidden = true
        }

        // 반응 알림 또는 댓글 알림에 따라 UI 설정
        switch notification.type {
        case .recordReaction:
            configureReactionNotification(notification)
        case .recordComment:
            configureCommentNotification(notification)
        case .friend, .unknown:
            configureDefaultNotification()
        }

        // 시간 표시 및 썸네일 여부에 따른 레이아웃 조정
        if timeLabel.isHidden {
            // 시간 라벨이 숨겨진 경우 - 메시지만 표시
            if thumbnailImageView.isHidden {
                // 썸네일도 없는 경우
                messageLabel.snp.remakeConstraints {
                    $0.leading.equalTo(profileImageView.snp.trailing).offset(Layout.textHorizontalSpacing)
                    $0.trailing.equalToSuperview().offset(-Layout.horizontalInset)
                    $0.top.equalToSuperview().offset(Layout.verticalInset)
                    $0.bottom.equalToSuperview().offset(-Layout.verticalInset)
                }
            } else {
                // 썸네일이 있는 경우
                messageLabel.snp.remakeConstraints {
                    $0.leading.equalTo(profileImageView.snp.trailing).offset(Layout.textHorizontalSpacing)
                    $0.trailing.equalTo(thumbnailImageView.snp.leading).offset(-Layout.textHorizontalSpacing)
                    $0.top.equalToSuperview().offset(Layout.verticalInset)
                    $0.bottom.equalToSuperview().offset(-Layout.verticalInset)
                }
            }

            timeLabel.snp.remakeConstraints {
                $0.leading.equalTo(profileImageView.snp.trailing).offset(Layout.textHorizontalSpacing)
                $0.trailing.equalToSuperview().offset(-Layout.horizontalInset)
                $0.top.equalToSuperview().offset(Layout.verticalInset)
            }
        } else {
            // 시간 라벨이 표시되는 경우
            if thumbnailImageView.isHidden {
                // 썸네일이 없는 경우
                timeLabel.snp.remakeConstraints {
                    $0.leading.equalTo(profileImageView.snp.trailing).offset(Layout.textHorizontalSpacing)
                    $0.trailing.equalToSuperview().offset(-Layout.horizontalInset)
                    $0.top.equalToSuperview().offset(Layout.verticalInset)
                }

                messageLabel.snp.remakeConstraints {
                    $0.leading.equalTo(timeLabel)
                    $0.trailing.equalTo(timeLabel)
                    $0.top.equalTo(timeLabel.snp.bottom).offset(Layout.textVerticalSpacing)
                    $0.bottom.equalToSuperview().offset(-Layout.verticalInset)
                }
            } else {
                // 썸네일이 있는 경우
                timeLabel.snp.remakeConstraints {
                    $0.leading.equalTo(profileImageView.snp.trailing).offset(Layout.textHorizontalSpacing)
                    $0.trailing.equalTo(thumbnailImageView.snp.leading).offset(-Layout.textHorizontalSpacing)
                    $0.top.equalToSuperview().offset(Layout.verticalInset)
                }

                messageLabel.snp.remakeConstraints {
                    $0.leading.equalTo(timeLabel)
                    $0.trailing.equalTo(timeLabel)
                    $0.top.equalTo(timeLabel.snp.bottom).offset(Layout.textVerticalSpacing)
                    $0.bottom.equalToSuperview().offset(-Layout.verticalInset)
                }
            }
        }

        // 안 읽은 알림 배경색 적용 (contentView에 적용하여 전체 너비)
        if !notification.read {
            contentView.backgroundColor = .bg004
        } else {
            contentView.backgroundColor = .clear
        }
    }

    private func configureReactionNotification(_ notification: NotificationItem) {
        // 감정 아이콘 표시
        reactionIconView.isHidden = false

        if let reaction = notification.reactionAlarm {
            reactionIconView.image = getReactionIcon(for: reaction.reactionType)
        }
    }

    private func configureCommentNotification(_ notification: NotificationItem) {
        // 감정 아이콘 숨김
        reactionIconView.isHidden = true
    }

    private func configureDefaultNotification() {
        // 기본 알림 (친구, 기타) - 감정 아이콘 숨김
        reactionIconView.isHidden = true
    }

    /// 감정 타입에 따른 아이콘 반환
    private func getReactionIcon(for reactionType: String) -> UIImage? {
        let icon: UIImage?
        switch reactionType {
        case "AWESOME":
            return .ReactionNotification.fire  // 멋져요 - 불
        case "AMAZING":
            return .ReactionNotification.congratulation  // 대단해 - 박수
        case "GREAT":
            return .ReactionNotification.nice  // 짱이야 - 좋아요
        case "FIGHTING":
            return .ReactionNotification.good  // 화이팅 - 주먹
        default:
            return .ReactionNotification.fire  // 기본값
        }
    }

    // MARK: - Actions

    @objc private func cellTapped() {
        guard let notification = notification else { return }
        delegate?.notificationCellDidTap(self, notification: notification)
    }
}
