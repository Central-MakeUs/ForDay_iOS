//
//  ActivityDetailPageViewController.swift
//  Forday
//
//  Created by Subeen on 3/31/26.
//

import UIKit
import SnapKit
import Then
import Combine

/// 활동 기록 상세 화면 페이징 컨테이너
/// 인스타그램 스타일의 세로 스와이프로 이전/다음 기록 탐색
final class ActivityDetailPageViewController: UIViewController {

    // MARK: - Properties

    private let pageViewController: UIPageViewController
    private var currentRecordId: Int
    private let context: ActivityDetailContext

    weak var coordinator: MainTabBarCoordinator?

    // 현재 표시 중인 DetailViewController
    private var currentDetailVC: ActivityDetailViewController? {
        didSet {
            bindCurrentDetail()
        }
    }

    // UI Components
    private let reactionUsersScrollView = ReactionUsersScrollView()
    private let reactionButtonsView = ReactionButtonsView()

    private var cancellables = Set<AnyCancellable>()
    private var childCancellables = Set<AnyCancellable>()

    // PageViewController의 내부 scrollView (제스처 제어용)
    private var pageScrollView: UIScrollView? {
        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }

    // 로딩 인디케이터 (위/아래)
    private let topLoadingIndicator = UIActivityIndicatorView(style: .medium)
    private let bottomLoadingIndicator = UIActivityIndicatorView(style: .medium)

    // 로딩 상태
    private var isLoadingPrev = false
    private var isLoadingNext = false

    // MARK: - Initialization

    init(recordId: Int, context: ActivityDetailContext) {
        self.currentRecordId = recordId
        self.context = context

        // UIPageViewController 설정 (세로 방향)
        self.pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: nil
        )

        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        setupLoadingIndicators()
        setupReactionViews()
        loadInitialViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Setup

extension ActivityDetailPageViewController {
    private func setupPageViewController() {
        // PageViewController를 자식으로 추가
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)

        pageViewController.delegate = self
        pageViewController.dataSource = self

        // 배경색
        view.backgroundColor = .systemBackground
        pageViewController.view.backgroundColor = .systemBackground
        
        // 내부 스크롤뷰 델리게이트 가로채기
        pageScrollView?.delegate = self
    }

    private func setupLoadingIndicators() {
        // 위쪽 로딩 인디케이터
        view.addSubview(topLoadingIndicator)
        topLoadingIndicator.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalToSuperview()
        }
        topLoadingIndicator.hidesWhenStopped = true

        // 아래쪽 로딩 인디케이터
        view.addSubview(bottomLoadingIndicator)
        bottomLoadingIndicator.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.centerX.equalToSuperview()
        }
        bottomLoadingIndicator.hidesWhenStopped = true
    }

    private func setupReactionViews() {
        view.addSubview(reactionUsersScrollView)
        view.addSubview(reactionButtonsView)

        reactionButtonsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(72) // 40(버튼) + 16(상단 패딩) + 16(하단 패딩)
        }

        reactionUsersScrollView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(reactionButtonsView.snp.top)
            $0.height.equalTo(0) // 초기값 0
        }

        // 반응 버튼 이벤트 연결
        reactionButtonsView.reactionSingleTapped
            .sink { [weak self] type in
                Task {
                    await self?.currentDetailVC?.viewModel.fetchReactionUsers(for: type)
                }
            }
            .store(in: &cancellables)

        reactionButtonsView.reactionDoubleTapped
            .sink { [weak self] type in
                Task {
                    await self?.currentDetailVC?.viewModel.toggleReaction(type)
                }
            }
            .store(in: &cancellables)

        reactionButtonsView.bookmarkTapped
            .sink { [weak self] in
                Task {
                    await self?.currentDetailVC?.viewModel.toggleScrap()
                }
            }
            .store(in: &cancellables)
    }

    private func bindCurrentDetail() {
        // 이전 자식 바인딩 제거
        childCancellables.removeAll()
        
        guard let detailVC = currentDetailVC else { return }

        // 상세 정보 갱신 감지하여 반응 버튼 업데이트
        detailVC.viewModel.$activityDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                guard let detail = detail else { return }
                self?.reactionButtonsView.configure(with: detail)
            }
            .store(in: &childCancellables)

        // 반응 유저 목록 업데이트
        detailVC.viewModel.$reactionUsers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                guard let self = self else { return }

                if users.isEmpty {
                    self.reactionUsersScrollView.isHidden = true
                    self.reactionUsersScrollView.clear()
                    self.reactionUsersScrollView.snp.updateConstraints { $0.height.equalTo(0) }
                } else {
                    self.reactionUsersScrollView.isHidden = false
                    self.reactionUsersScrollView.configure(with: users)
                    self.reactionUsersScrollView.snp.updateConstraints { $0.height.equalTo(60) }
                }

                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &childCancellables)
    }

    private func loadInitialViewController() {
        let detailVC = createDetailViewController(for: currentRecordId)
        currentDetailVC = detailVC

        pageViewController.setViewControllers(
            [detailVC],
            direction: .forward,
            animated: false
        )
    }
}

// MARK: - ViewController Creation

extension ActivityDetailPageViewController {
    /// 특정 recordId에 대한 ActivityDetailViewController 생성
    private func createDetailViewController(for recordId: Int) -> ActivityDetailViewController {
        let viewModel = ActivityDetailViewModel(activityRecordId: recordId, context: context)
        let detailVC = ActivityDetailViewController(viewModel: viewModel)
        detailVC.coordinator = coordinator

        return detailVC
    }
}

// MARK: - UIPageViewControllerDataSource

extension ActivityDetailPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let detailVC = viewController as? ActivityDetailViewController,
              let prevRecordId = detailVC.viewModel.prevRecordId else {
            return nil
        }

        return createDetailViewController(for: prevRecordId)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let detailVC = viewController as? ActivityDetailViewController,
              let nextRecordId = detailVC.viewModel.nextRecordId else {
            return nil
        }

        return createDetailViewController(for: nextRecordId)
    }
}

// MARK: - UIPageViewControllerDelegate

extension ActivityDetailPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        // 전환 시작 시 로딩 인디케이터 표시
        if let detailVC = pendingViewControllers.first as? ActivityDetailViewController {
            let recordId = detailVC.viewModel.activityRecordId

            // 이전 기록으로 이동 중
            if let currentVC = currentDetailVC,
               recordId == currentVC.viewModel.prevRecordId {
                topLoadingIndicator.startAnimating()
                isLoadingPrev = true
            }
            // 다음 기록으로 이동 중
            else if let currentVC = currentDetailVC,
                    recordId == currentVC.viewModel.nextRecordId {
                bottomLoadingIndicator.startAnimating()
                isLoadingNext = true
            }
        }
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        // 전환 완료 시
        if completed {
            if let detailVC = pageViewController.viewControllers?.first as? ActivityDetailViewController {
                currentDetailVC = detailVC
                currentRecordId = detailVC.viewModel.activityRecordId
            }
        }

        // 로딩 인디케이터 숨김
        if isLoadingPrev {
            topLoadingIndicator.stopAnimating()
            isLoadingPrev = false
        }
        if isLoadingNext {
            bottomLoadingIndicator.stopAnimating()
            isLoadingNext = false
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ActivityDetailPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // pageScrollView인 경우에만 로직 실행
        guard scrollView === pageScrollView else { return }

        let offsetY = scrollView.contentOffset.y
        let frameHeight = scrollView.frame.height

        // 위로 스와이프 (다음 글로 가기 시도)
        if offsetY > frameHeight {
            if let currentVC = currentDetailVC, !currentVC.canPageToNext {
                // 더 이상 스크롤할 수 없는 상태가 아니면 페이징 막기
                scrollView.contentOffset.y = frameHeight
            }
        }
        // 아래로 스와이프 (이전 글로 가기 시도)
        else if offsetY < frameHeight {
            if let currentVC = currentDetailVC, !currentVC.canPageToPrevious {
                // 최상단이 아니면 페이징 막기
                scrollView.contentOffset.y = frameHeight
            }
        }
    }
}
