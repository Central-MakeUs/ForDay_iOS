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
    private let thumbnailImageView = UIImageView()
    private let reactionIconView = UIImageView()
    private let messageLabel = UILabel()
    private let commentLabel = UILabel()
    private let separatorView = UIView()

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
        contentView.backgroundColor = .clear

        containerView.do {
            $0.backgroundColor = .clear
        }

        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.backgroundColor = .neutral100
        }

        reactionIconView.do {
            $0.contentMode = .center
            $0.backgroundColor = .primary002
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.action001.cgColor
            $0.clipsToBounds = true
        }

        messageLabel.do {
            $0.font = TypographyStyle.label14.font
            $0.textColor = .neutral800
            $0.numberOfLines = 0
        }

        commentLabel.do {
            $0.font = TypographyStyle.label14.font
            $0.textColor = .neutral500
            $0.numberOfLines = 1
        }

        separatorView.do {
            $0.backgroundColor = .neutral100
        }
    }

    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(reactionIconView)
        containerView.addSubview(messageLabel)
        containerView.addSubview(commentLabel)
        containerView.addSubview(separatorView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }

        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
            $0.size.equalTo(48)
        }

        reactionIconView.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImageView.snp.leading).offset(28)
            $0.top.equalTo(thumbnailImageView.snp.top).offset(28)
            $0.size.equalTo(24)
        }

        messageLabel.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(12)
        }

        commentLabel.snp.makeConstraints {
            $0.leading.equalTo(messageLabel)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(messageLabel.snp.bottom).offset(4)
        }

        separatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
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

        // 썸네일 이미지
        if let imageUrl = notification.imageUrl {
            thumbnailImageView.setImage(with: imageUrl)
        } else {
            thumbnailImageView.backgroundColor = .bg003
            thumbnailImageView.image = nil
        }

        // 메시지
        messageLabel.text = notification.message

        // 반응 알림 또는 댓글 알림에 따라 UI 설정
        switch notification.type {
        case .recordReaction:
            configureReactionNotification(notification)
        case .recordComment:
            configureCommentNotification(notification)
        case .friend, .unknown:
            configureDefaultNotification()
        }

        // TODO: 읽지 않은 알림 표시 (read 필드 활용)
        // if !notification.read {
        //     // 읽지 않은 알림 스타일 적용 (예: 배경색, 폰트 등)
        // }
    }

    private func configureReactionNotification(_ notification: NotificationItem) {
        // 감정 아이콘 표시
        reactionIconView.isHidden = false
        commentLabel.isHidden = true

        if let reaction = notification.reactionAlarm {
            reactionIconView.image = getReactionIcon(for: reaction.reactionType)
        }

        // 높이 조정
        containerView.snp.remakeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            $0.height.equalTo(72)
        }
    }

    private func configureCommentNotification(_ notification: NotificationItem) {
        // 감정 아이콘 숨김, 댓글 내용 표시
        reactionIconView.isHidden = true
        commentLabel.isHidden = false

        if let comment = notification.commentAlarm {
            commentLabel.text = comment.commentContent
        }

        // 높이 조정
        containerView.snp.remakeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            $0.height.equalTo(72)
        }
    }

    private func configureDefaultNotification() {
        // 기본 알림 (친구, 기타)
        reactionIconView.isHidden = true
        commentLabel.isHidden = true

        containerView.snp.remakeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            $0.height.equalTo(72)
        }
    }

    /// 감정 타입에 따른 아이콘 반환
    private func getReactionIcon(for reactionType: String) -> UIImage? {
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
