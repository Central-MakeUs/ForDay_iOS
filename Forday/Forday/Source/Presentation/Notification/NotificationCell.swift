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
            $0.contentMode = .center
            $0.backgroundColor = .primary002
            $0.layer.cornerRadius = 8  // 16 / 2
            $0.layer.borderWidth = 0.667
            $0.layer.borderColor = UIColor.action001.cgColor
            $0.clipsToBounds = true
        }

        timeLabel.do {
            $0.font = TypographyStyle.label12.font
            $0.textColor = .neutral400
            $0.numberOfLines = 1
        }

        messageLabel.do {
            $0.font = TypographyStyle.label14.font
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
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(36)
        }

        // 감정 아이콘 (프로필 오른쪽 하단에 오버레이)
        reactionIconView.snp.makeConstraints {
            $0.trailing.equalTo(profileImageView.snp.trailing).offset(-2)
            $0.bottom.equalTo(profileImageView.snp.bottom).offset(-2)
            $0.size.equalTo(16)
        }

        // 텍스트 컨테이너 (시간 + 메시지)
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(thumbnailImageView.snp.leading).offset(-8)
            $0.top.equalToSuperview().offset(10)
        }

        messageLabel.snp.makeConstraints {
            $0.leading.equalTo(timeLabel)
            $0.trailing.equalTo(timeLabel)
            $0.top.equalTo(timeLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-10)
        }

        // 활동 사진 (오른쪽, 20pt 패딩)
        thumbnailImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(48)
        }

        // 구분선 (전체 너비)
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

        // 프로필 이미지
        if let profileUrl = notification.senderProfileUrl {
            profileImageView.setImage(with: profileUrl)
        } else {
            profileImageView.backgroundColor = .neutral100
            profileImageView.image = nil
        }

        // 시간 (빈 문자열이 아닐 때만 표시)
        if !notification.createdAt.isEmpty {
            timeLabel.text = notification.createdAt
            timeLabel.isHidden = false
        } else {
            timeLabel.isHidden = true
        }

        // 메시지
        messageLabel.text = notification.message

        // 활동 사진
        if let imageUrl = notification.imageUrl {
            thumbnailImageView.setImage(with: imageUrl)
        } else {
            thumbnailImageView.backgroundColor = .bg003
            thumbnailImageView.image = nil
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

        // 시간 표시 여부에 따른 레이아웃 조정
        if timeLabel.isHidden {
            messageLabel.snp.remakeConstraints {
                $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
                $0.trailing.equalTo(thumbnailImageView.snp.leading).offset(-8)
                $0.top.equalToSuperview().offset(10)
                $0.bottom.equalToSuperview().offset(-10)
            }
        } else {
            messageLabel.snp.remakeConstraints {
                $0.leading.equalTo(timeLabel)
                $0.trailing.equalTo(timeLabel)
                $0.top.equalTo(timeLabel.snp.bottom).offset(4)
                $0.bottom.equalToSuperview().offset(-10)
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
