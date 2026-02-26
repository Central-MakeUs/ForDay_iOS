//
//  ActivityDetailDropdownView.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import UIKit
import SnapKit
import Then

enum ActivityDetailDropdownOption: CaseIterable {
    case setCoverImage
    case edit
    case delete
    case report

    var title: String {
        switch self {
        case .setCoverImage: return "대표사진 설정"
        case .edit: return "수정하기"
        case .delete: return "삭제하기"
        case .report: return "신고하기"
        }
    }

    var icon: UIImage? {
        switch self {
        case .setCoverImage:
            return .Icon.image
        case .edit:
            return .Icon.edit
        case .delete:
            return .Icon.trash
        case .report:
            return .Icon.report
        }
    }

    /// 소유자 전용 옵션
    static var ownerOptions: [ActivityDetailDropdownOption] {
        return [.setCoverImage, .edit, .delete]
    }

    /// 소유자 전용 옵션 (이미지 없는 경우)
    static var ownerOptionsWithoutCover: [ActivityDetailDropdownOption] {
        return [.edit, .delete]
    }

    /// 비소유자 옵션
    static var nonOwnerOptions: [ActivityDetailDropdownOption] {
        return [.report]
    }
}

final class ActivityDetailDropdownView: UIView {

    // MARK: - Properties

    private let tableView = UITableView()
    private var options: [ActivityDetailDropdownOption] = []

    var onOptionSelected: ((ActivityDetailDropdownOption) -> Void)?

    // MARK: - Initialization

    /// 드롭다운 뷰 초기화
    /// - Parameters:
    ///   - isOwner: 게시글 소유자 여부
    ///   - showCoverImageOption: 대표사진 설정 옵션 표시 여부 (소유자일 때만 의미 있음)
    init(isOwner: Bool, showCoverImageOption: Bool = true) {
        super.init(frame: .zero)

        if isOwner {
            // 소유자: 수정, 삭제, 대표사진 설정 (이미지 있는 경우)
            if showCoverImageOption {
                options = ActivityDetailDropdownOption.ownerOptions
            } else {
                options = ActivityDetailDropdownOption.ownerOptionsWithoutCover
            }
        } else {
            // 비소유자: 신고하기만
            options = ActivityDetailDropdownOption.nonOwnerOptions
        }

        style()
        layout()
        setupTableView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        options = ActivityDetailDropdownOption.ownerOptions
        style()
        layout()
        setupTableView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension ActivityDetailDropdownView {
    private func style() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 12

        tableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.isScrollEnabled = false
            $0.bounces = false
            $0.showsVerticalScrollIndicator = false
            $0.clipsToBounds = true
        }
    }

    private func layout() {
        addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ActivityDetailDropdownCell.self, forCellReuseIdentifier: ActivityDetailDropdownCell.identifier)
    }
}

// MARK: - Public Methods

extension ActivityDetailDropdownView {
    func show(in parentView: UIView, below sourceView: UIView) {
        parentView.addSubview(self)

        // 3개 옵션 고정
        let rowHeight: CGFloat = 44  // 8px padding + icon/text + 8px padding
        let totalHeight = CGFloat(options.count) * rowHeight

        self.snp.makeConstraints {
            $0.top.equalTo(sourceView.snp.bottom).offset(8)
            $0.trailing.equalTo(sourceView)
            $0.width.equalTo(167)  // Figma design width
            $0.height.equalTo(totalHeight)
        }

        // Fade in animation
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

// MARK: - UITableViewDataSource

extension ActivityDetailDropdownView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActivityDetailDropdownCell.identifier, for: indexPath) as? ActivityDetailDropdownCell else {
            return UITableViewCell()
        }

        let option = options[indexPath.row]
        cell.configure(with: option)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ActivityDetailDropdownView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.row]
        onOptionSelected?(selectedOption)
    }
}

// MARK: - ActivityDetailDropdownCell

final class ActivityDetailDropdownCell: UITableViewCell {

    static let identifier = "ActivityDetailDropdownCell"

    // MARK: - UI Components

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with option: ActivityDetailDropdownOption) {
        iconImageView.image = option.icon
        titleLabel.setTextWithTypography(option.title, style: .body16)

        // 삭제하기는 빨간색
        if option == .delete {
            titleLabel.textColor = .secondary003
            iconImageView.tintColor = .secondary003
        } else {
            titleLabel.textColor = .neutral800
            iconImageView.tintColor = .neutral800
        }
    }
}

// MARK: - Setup

extension ActivityDetailDropdownCell {
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }

        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .neutral800
        }

        titleLabel.do {
            $0.textColor = .neutral800
        }

        contentView.addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)

        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }
    }
}
