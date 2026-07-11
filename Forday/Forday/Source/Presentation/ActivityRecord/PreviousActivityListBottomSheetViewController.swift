//
//  PreviousActivityListBottomSheetViewController.swift
//  Forday
//
//  Created by Subeen on 6/14/26.
//

import UIKit
import SnapKit
import Then

/// 이전 활동 데이터 모델
struct PreviousActivity {
    let id: Int
    let name: String
    let count: Int
}

/// 이전 활동리스트 바텀시트 뷰 컨트롤러
final class PreviousActivityListBottomSheetViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let headerHeight: CGFloat = 40 + 19 + 24  // top padding + title + gap
        static let subtitleHeight: CGFloat = 20 + 10      // subtitle + gap
        static let cardHeight: CGFloat = 52
        static let cardGap: CGFloat = 10
        static let bottomButtonHeight: CGFloat = 88
        static let horizontalPadding: CGFloat = 20
        static let maxVisibleItems = 5
        static let emptyStateHeight: CGFloat = 300
    }

    // MARK: - UI Components

    private let dimmerView = UIView()
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let collectionView: UICollectionView
    private let emptyStateView = UIView()
    private let emptyIconImageView = UIImageView()
    private let emptyLabel = UILabel()
    private let submitButton = UIButton()

    // MARK: - Properties

    private var activities: [PreviousActivity] = []
    private var selectedActivityId: Int?
    private var containerHeightConstraint: Constraint?
    private var hasAnimatedIn = false

    /// 선택 완료 시 콜백
    var onActivitySelected: ((PreviousActivity) -> Void)?

    // MARK: - Initialization

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Constants.cardGap
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupCollectionView()
        setupGestures()

        // TODO: API 연결 후 실제 데이터로 교체
        loadMockData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !hasAnimatedIn else { return }
        prepareInitialState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAnimatedIn else { return }
        hasAnimatedIn = true
        animateIn()
    }

    // MARK: - Configuration

    /// 활동 목록 설정
    func configure(with activities: [PreviousActivity]) {
        self.activities = activities
        updateUI()
    }
}

// MARK: - Setup

extension PreviousActivityListBottomSheetViewController {
    private func style() {
        view.backgroundColor = .clear

        dimmerView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }

        containerView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 20
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.clipsToBounds = true
        }

        titleLabel.do {
            $0.setTextWithTypography("이전 활동리스트", style: .header16)
            $0.textColor = .neutral800
            $0.textAlignment = .center
        }

        subtitleLabel.do {
            $0.setTextWithTypography("3개월 이내에 기록된 활동", style: .label14)
            $0.textColor = .neutral400
        }

        collectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = false
        }

        // Empty State
        emptyStateView.do {
            $0.isHidden = true
        }

        emptyIconImageView.do {
            $0.image = .Icon.sorryBubble
            $0.contentMode = .scaleAspectFit
        }

        emptyLabel.do {
            $0.setTextWithTypography("아직 최근 활동이 존재하지 않아요.", style: .label14)
            $0.textColor = .neutral400
            $0.textAlignment = .center
        }

        submitButton.do {
            var config = UIButton.Configuration.filled()
            config.attributedTitle = AttributedString(
                "선택 완료",
                attributes: AttributeContainer(TypographyStyle.header16.attributes)
            )
            config.baseForegroundColor = .neutralWhite
            config.baseBackgroundColor = .action001
            config.cornerStyle = .fixed
            config.background.cornerRadius = 12
            $0.configuration = config
        }
    }

    private func layout() {
        view.addSubview(dimmerView)
        view.addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(collectionView)
        containerView.addSubview(emptyStateView)
        containerView.addSubview(submitButton)

        emptyStateView.addSubview(emptyIconImageView)
        emptyStateView.addSubview(emptyLabel)

        dimmerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            containerHeightConstraint = $0.height.equalTo(calculateSheetHeight()).constraint
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(Constants.horizontalPadding)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            $0.bottom.equalTo(submitButton.snp.top).offset(-16)
        }

        emptyStateView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
            $0.bottom.equalTo(submitButton.snp.top).offset(-16)
        }

        emptyIconImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(40)
            $0.width.height.equalTo(48)
        }

        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(emptyIconImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }

        submitButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(56)
        }
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            PreviousActivityCell.self,
            forCellWithReuseIdentifier: "PreviousActivityCell"
        )
    }

    private func setupGestures() {
        // Dimmer tap to dismiss
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(dimmerTapped))
        dimmerView.addGestureRecognizer(dimmerTap)

        // Submit button action
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }

    private func setupPanGestureIfNeeded() {
        // 기존 Pan 제스처 제거
        containerView.gestureRecognizers?
            .filter { $0 is UIPanGestureRecognizer }
            .forEach { containerView.removeGestureRecognizer($0) }

        // Pan gesture for dragging (only if more than 5 items)
        guard activities.count > Constants.maxVisibleItems else { return }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        containerView.addGestureRecognizer(panGesture)
    }

    private func loadMockData() {
        // TODO: API 연결 후 실제 데이터로 교체
        let mockActivities: [PreviousActivity] = [
            PreviousActivity(id: 1, name: "한 챕터마다 독후감 쓰기", count: 5),
            PreviousActivity(id: 2, name: "미라클 모닝 아침 독서", count: 4),
            PreviousActivity(id: 3, name: "공원에서 책 읽기", count: 3),
            PreviousActivity(id: 4, name: "SNS 독서 인증", count: 2),
            PreviousActivity(id: 5, name: "독서 클럽 참여", count: 1)
        ]
        configure(with: mockActivities)
    }
}

// MARK: - UI Updates

extension PreviousActivityListBottomSheetViewController {
    private func updateUI() {
        let isEmpty = activities.isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        subtitleLabel.isHidden = isEmpty

        updateSheetHeight()
        collectionView.reloadData()
        updateSubmitButtonState()
        setupPanGestureIfNeeded()
    }

    private func calculateSheetHeight() -> CGFloat {
        if activities.isEmpty {
            return Constants.emptyStateHeight
        }

        let itemCount = min(activities.count, Constants.maxVisibleItems)
        let cardsHeight = CGFloat(itemCount) * Constants.cardHeight + CGFloat(itemCount - 1) * Constants.cardGap
        let totalHeight = Constants.headerHeight + Constants.subtitleHeight + cardsHeight + Constants.bottomButtonHeight

        return totalHeight
    }

    private func updateSheetHeight() {
        containerHeightConstraint?.update(offset: calculateSheetHeight())
        view.layoutIfNeeded()
    }

    private func updateSubmitButtonState() {
        let hasSelection = selectedActivityId != nil
        submitButton.isEnabled = hasSelection
        submitButton.alpha = hasSelection ? 1.0 : 0.5
    }
}

// MARK: - Actions

extension PreviousActivityListBottomSheetViewController {
    @objc private func dimmerTapped() {
        animateOut()
    }

    @objc private func submitButtonTapped() {
        guard let selectedId = selectedActivityId,
              let selectedActivity = activities.first(where: { $0.id == selectedId }) else {
            return
        }

        animateOut { [weak self] in
            self?.onActivitySelected?(selectedActivity)
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard activities.count > Constants.maxVisibleItems else { return }

        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            let minHeight = calculateSheetHeight()
            let maxHeight = calculateMaxExpandedHeight()
            let currentHeight = containerHeightConstraint?.layoutConstraints.first?.constant ?? minHeight
            let newHeight = currentHeight - translation.y
            let clampedHeight = max(minHeight, min(maxHeight, newHeight))
            containerHeightConstraint?.update(offset: clampedHeight)
            view.layoutIfNeeded()
            gesture.setTranslation(.zero, in: view)

        case .ended:
            let minHeight = calculateSheetHeight()
            let maxHeight = calculateMaxExpandedHeight()
            let currentHeight = containerHeightConstraint?.layoutConstraints.first?.constant ?? minHeight

            let targetHeight: CGFloat
            if velocity.y < -500 {
                targetHeight = maxHeight
            } else if velocity.y > 500 {
                if currentHeight < minHeight + 50 {
                    animateOut()
                    return
                }
                targetHeight = minHeight
            } else {
                let midpoint = (minHeight + maxHeight) / 2
                targetHeight = currentHeight > midpoint ? maxHeight : minHeight
            }

            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
                self.containerHeightConstraint?.update(offset: targetHeight)
                self.view.layoutIfNeeded()
            }

        default:
            break
        }
    }

    private func calculateMaxExpandedHeight() -> CGFloat {
        let allCardsHeight = CGFloat(activities.count) * Constants.cardHeight + CGFloat(activities.count - 1) * Constants.cardGap
        let totalHeight = Constants.headerHeight + Constants.subtitleHeight + allCardsHeight + Constants.bottomButtonHeight
        let maxAvailable = view.bounds.height - view.safeAreaInsets.top - 40
        return min(totalHeight, maxAvailable)
    }
}

// MARK: - Animation

extension PreviousActivityListBottomSheetViewController {
    private func prepareInitialState() {
        view.layoutIfNeeded()
        dimmerView.alpha = 0
        containerView.transform = CGAffineTransform(translationX: 0, y: calculateSheetHeight())
    }

    private func animateIn() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.dimmerView.alpha = 1
            self.containerView.transform = .identity
        }
    }

    private func animateOut(completion: (() -> Void)? = nil) {
        let height = containerHeightConstraint?.layoutConstraints.first?.constant ?? calculateSheetHeight()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.dimmerView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: height)
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension PreviousActivityListBottomSheetViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PreviousActivityCell",
            for: indexPath
        ) as? PreviousActivityCell else {
            return UICollectionViewCell()
        }

        let activity = activities[indexPath.item]
        let isSelected = activity.id == selectedActivityId
        cell.configure(activityName: activity.name, count: activity.count, isSelected: isSelected)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension PreviousActivityListBottomSheetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activity = activities[indexPath.item]

        // Toggle selection (단일 선택)
        if selectedActivityId == activity.id {
            selectedActivityId = nil
        } else {
            selectedActivityId = activity.id
        }

        collectionView.reloadData()
        updateSubmitButtonState()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PreviousActivityListBottomSheetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: Constants.cardHeight)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PreviousActivityListBottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = panGesture.velocity(in: view)
        return abs(velocity.y) > abs(velocity.x)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
