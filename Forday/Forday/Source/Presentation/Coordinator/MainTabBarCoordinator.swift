//
//  MainTabBarCoordinator.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import UIKit

class MainTabBarCoordinator: NSObject, Coordinator {


    let navigationController: UINavigationController
    let tabBarController: UITabBarController = UITabBarController()

    weak var parentCoordinator: AppCoordinator?
    private weak var homeViewController: HomeViewController?
    private var onboardingCoordinator: OnboardingCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }

    func start() {
        setupTabBar()
    }

    private func setupTabBar() {
        // 홈 탭
        let homeVC = HomeViewController()
        homeVC.coordinator = self
        homeVC.tabBarItem = UITabBarItem(
            title: "홈",
            image: .Gnb.home,
            selectedImage: .Gnb.homeFill
        )
        self.homeViewController = homeVC
        let homeNav = createNavigationController(rootViewController: homeVC)

        // 발견 탭
        let discoverVC = DiscoverViewController()
        discoverVC.coordinator = self
        discoverVC.tabBarItem = UITabBarItem(
            title: "발견",
            image: .Gnb.recommendation,
            selectedImage: .Gnb.recommendationFill
        )
        let discoverNav = createNavigationController(rootViewController: discoverVC)

        // 작성 탭 (더미 - 실제로는 presentActivityRecord()에서 present됨)
        let recordVC = UIViewController()
        recordVC.tabBarItem = UITabBarItem(
            title: "",
            image: .Gnb.write,
            selectedImage: .Gnb.write
        )

        // 소식 탭
        let storiesVC = StoriesViewController()
        storiesVC.coordinator = self
        storiesVC.tabBarItem = UITabBarItem(
            title: "소식",
            image: .Gnb.story,
            selectedImage: .Gnb.storyFill
        )
        let storiesNav = createNavigationController(rootViewController: storiesVC)

        // 프로필 탭
        let profileVC = MyPageViewController()
        profileVC.coordinator = self
        profileVC.view.backgroundColor = .systemBackground
        profileVC.title = "마이"
        profileVC.tabBarItem = UITabBarItem(
            title: "마이",
            image: .Gnb.myPage,
            selectedImage: .Gnb.myPageFill
        )
        let profileNav = createNavigationController(rootViewController: profileVC)

        // TabBar 설정 (홈, 발견, 작성, 소식, 마이)
        tabBarController.viewControllers = [
            homeNav,
            discoverNav,
            recordVC,
            storiesNav,
            profileNav,
        ]

        tabBarController.delegate = self
        tabBarController.tabBar.tintColor = .neutral900
        tabBarController.tabBar.backgroundColor = .neutralWhite
    }

    private func createNavigationController(rootViewController: UIViewController) -> UINavigationController {
        let nav = BaseNavigationController(rootViewController: rootViewController)

        // 네비게이션 바 기본 설정
        nav.navigationBar.prefersLargeTitles = false
        nav.navigationBar.isTranslucent = true

        // 네비게이션 바를 상태바 바로 아래에 배치
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.compactAppearance = appearance

        return nav
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabBarCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        // 작성 탭(index 2) 선택 시
        if let viewControllers = tabBarController.viewControllers,
           viewControllers.firstIndex(of: viewController) == 2 {

            // ActivityRecordViewController present
            presentActivityRecord()

            return false  // 탭 전환 막음
        }

        return true  // 다른 탭은 정상 전환
    }
    
    private func presentActivityRecord() {
        // 오늘 이미 활동 기록을 완료했는지 확인
        if homeViewController?.isActivityRecordedToday() == true {
            showAlreadyRecordedPopup()
            return
        }

        // HomeViewController에서 currentHobbyId 가져오기
        guard let hobbyId = homeViewController?.getCurrentHobbyId() else {
            print("❌ 취미 ID 없음 - ActivityRecordViewController를 표시할 수 없습니다")
            return
        }

        let hobbyName = homeViewController?.getCurrentHobbyName() ?? "취미"
        let preselectedActivityId = homeViewController?.getCurrentActivityId()

        let recordVC = ActivityRecordViewController(
            hobbyId: hobbyId,
            hobbyName: hobbyName,
            preselectedActivityId: preselectedActivityId
        )
        recordVC.coordinator = self
        let nav = BaseNavigationController(rootViewController: recordVC)
        nav.modalPresentationStyle = .fullScreen

        // 현재 선택된 탭의 ViewController에서 present
        if let selectedVC = tabBarController.selectedViewController {
            selectedVC.present(nav, animated: true)
        }
    }

    /// 오늘 이미 활동 기록을 완료한 경우 팝업 표시
    private func showAlreadyRecordedPopup() {
        let popup = CommonPopupViewController(
            title: "활동 기록은 하루에 1개만 가능해요",
            message: "이미 오늘의 활동을 기록하셨어요. 다른 활동을 기록하고 싶다면, 이전 활동 기록을 삭제해야 돼요.",
            primaryButtonTitle: "기록 보러가기",
            secondaryButtonTitle: "닫기"
        )

        // 기록 보러가기 버튼 액션
        popup.onPrimaryAction = { [weak self] in
            guard let self = self,
                  let recordId = self.homeViewController?.getLastActivityRecordId() else {
                return
            }
            self.showActivityDetail(activityRecordId: recordId)
        }

        // 닫기 버튼 액션 (dismiss만 - 기본 동작)
        popup.onSecondaryAction = nil

        // 현재 선택된 탭에서 present
        if let selectedVC = tabBarController.selectedViewController {
            selectedVC.present(popup, animated: true)
        }
    }

    func showHobbySettings() {
        // Create UseCases
        let fetchHobbySettingsUseCase = FetchHobbySettingsUseCase()
        let updateHobbyTimeUseCase = UpdateHobbyTimeUseCase()
        let updateExecutionCountUseCase = UpdateExecutionCountUseCase()
        let updateGoalDaysUseCase = UpdateGoalDaysUseCase()
        let updateHobbyStatusUseCase = UpdateHobbyStatusUseCase()

        // Create ViewModel
        let viewModel = HobbySettingsViewModel(
            fetchHobbySettingsUseCase: fetchHobbySettingsUseCase,
            updateHobbyTimeUseCase: updateHobbyTimeUseCase,
            updateExecutionCountUseCase: updateExecutionCountUseCase,
            updateGoalDaysUseCase: updateGoalDaysUseCase,
            updateHobbyStatusUseCase: updateHobbyStatusUseCase
        )

        // Create ViewController
        let hobbySettingsVC = HobbySettingsViewController(viewModel: viewModel)
        hobbySettingsVC.coordinator = self
        hobbySettingsVC.hidesBottomBarWhenPushed = true  // 탭바 숨김

        // Push to Home navigation stack (스와이프 백 지원)
        if let homeNav = tabBarController.viewControllers?.first as? UINavigationController {
            homeNav.pushViewController(hobbySettingsVC, animated: true)
        }
    }

    func showProfileSettings() {
        // Create ViewController
        let profileSettingsVC = ProfileSettingsViewController()
        profileSettingsVC.coordinator = self
        profileSettingsVC.hidesBottomBarWhenPushed = true  // 탭바 숨김

        // Push to MyPage navigation stack
        if let myPageNav = tabBarController.viewControllers?.last as? UINavigationController {
            // Hide navigation bar before pushing to avoid flash
            myPageNav.setNavigationBarHidden(true, animated: false)
            myPageNav.pushViewController(profileSettingsVC, animated: true)
        }
    }

    func showGeneralSettings() {
        // Create ViewController
        let generalSettingsVC = GeneralSettingsViewController()
        generalSettingsVC.coordinator = self
        generalSettingsVC.hidesBottomBarWhenPushed = true  // 탭바 숨김

        // Push to current navigation stack (스와이프 백 지원)
        if let currentNav = tabBarController.selectedViewController as? UINavigationController {
            currentNav.pushViewController(generalSettingsVC, animated: true)
        } else if let myPageNav = tabBarController.viewControllers?.last as? UINavigationController {
            myPageNav.pushViewController(generalSettingsVC, animated: true)
        }
    }

    func showActivityDetail(activityRecordId: Int) {
        // Create context for current user's feed (matches MyPage/Home)
        // This ensures the detail view has a navigation bar (via ActivityDetailPageViewController)
        let context = ActivityDetailContext(
            contextType: .userFeed,
            userId: nil,
            keyword: nil,
            hobbyIds: nil
        )
        showActivityDetailWithContext(activityRecordId: activityRecordId, context: context)
    }

    /// 활동 기록 상세 보기 (스와이프 가능 모드)
    func showActivityDetailWithContext(activityRecordId: Int, context: ActivityDetailContext) {
        let pageVC = ActivityDetailPageViewController(recordId: activityRecordId, context: context)
        pageVC.coordinator = self

        if let currentNav = tabBarController.selectedViewController as? UINavigationController {
            currentNav.pushViewController(pageVC, animated: true)
        }
    }

    /// 활동 기록 완료 후 상세 보기 표시
    /// - Parameters:
    ///   - activityRecordId: 기록 ID
    ///   - nickname: 사용자 닉네임 (로띠 메시지에 사용)
    ///   - from: 현재 표시 중인 ViewController (dismiss 용)
    func showActivityDetailAfterRecord(activityRecordId: Int, nickname: String, from presentingVC: UIViewController) {
        // Create ViewModel
        let viewModel = ActivityDetailViewModel(activityRecordId: activityRecordId)

        // Create ViewController with afterRecord mode
        let detailVC = ActivityDetailViewController(
            viewModel: viewModel,
            displayMode: .afterRecord,
            nickname: nickname
        )
        detailVC.coordinator = self
        detailVC.modalPresentationStyle = .fullScreen

        // 현재 present된 화면 dismiss 후 새 화면 표시
        presentingVC.dismiss(animated: false) { [weak self] in
            // Home navigation에서 present
            if let homeNav = self?.tabBarController.viewControllers?.first as? UINavigationController {
                homeNav.present(detailVC, animated: true)
            }
        }
    }

    func showActivityRecord() {
        // Get current hobby ID from HomeViewController
        guard let hobbyId = homeViewController?.getCurrentHobbyId() else {
            print("❌ 취미 ID 없음 - ActivityRecordViewController를 표시할 수 없습니다")
            return
        }

        let hobbyName = homeViewController?.getCurrentHobbyName() ?? "취미"
        let preselectedActivityId = homeViewController?.getCurrentActivityId()

        let recordVC = ActivityRecordViewController(
            hobbyId: hobbyId,
            hobbyName: hobbyName,
            preselectedActivityId: preselectedActivityId
        )
        recordVC.coordinator = self
        let nav = BaseNavigationController(rootViewController: recordVC)
        nav.modalPresentationStyle = .fullScreen

        // Present from Home navigation stack
        if let homeNav = tabBarController.viewControllers?.first as? UINavigationController {
            homeNav.present(nav, animated: true)
        }
    }

    /// MyPage에서 특정 취미로 활동 기록 화면 표시
    func showActivityRecord(hobbyId: Int, hobbyName: String) {
        let recordVC = ActivityRecordViewController(
            hobbyId: hobbyId,
            hobbyName: hobbyName,
            preselectedActivityId: nil
        )
        recordVC.coordinator = self
        let nav = BaseNavigationController(rootViewController: recordVC)
        nav.modalPresentationStyle = .fullScreen

        // Present from current selected tab
        if let selectedVC = tabBarController.selectedViewController {
            selectedVC.present(nav, animated: true)
        }
    }

    func showAddHobbyOnboarding() {
        // Get home navigation controller
        guard let homeNav = tabBarController.viewControllers?.first as? UINavigationController else {
            print("❌ Home navigation controller not found")
            return
        }

        // Create onboarding navigation controller
        let onboardingNav = UINavigationController()
        onboardingNav.modalPresentationStyle = .fullScreen

        // Create onboarding coordinator
        onboardingCoordinator = OnboardingCoordinator(navigationController: onboardingNav)

        // 취미 추가 모드로 설정 (이미 생성한 취미 제외)
        onboardingCoordinator?.hobbySelectionMode = .addHobby

        // Set completion handler to dismiss and refresh home
        onboardingCoordinator?.onHobbyCreationCompleted = { [weak self] in
            // Dismiss onboarding
            onboardingNav.dismiss(animated: true) { [weak self] in
                // Refresh home view
                Task { [weak self] in
                    await self?.homeViewController?.viewModel.fetchHomeInfo()
                }
                // Clean up coordinator reference
                self?.onboardingCoordinator = nil
            }
        }

        // Start onboarding
        onboardingCoordinator?.start()

        // Present onboarding
        homeNav.present(onboardingNav, animated: true)
    }

    func updateTabBarRecordingButtonState(enabled: Bool) {
        // Get recording tab (index 2)
        guard let recordVC = tabBarController.viewControllers?[2] else { return }
        recordVC.tabBarItem.isEnabled = enabled
    }

    func showUserProfile(userId: String) {
        let profileVC = UserProfileViewController(userId: userId)
        profileVC.coordinator = self

        // Push to current navigation stack (enables swipe back gesture)
        if let currentNav = tabBarController.selectedViewController as? UINavigationController {
            currentNav.pushViewController(profileVC, animated: true)
        } else if let storiesNav = tabBarController.viewControllers?[3] as? UINavigationController {
            // Fallback to stories navigation (most likely source of user profile navigation)
            storiesNav.pushViewController(profileVC, animated: true)
        } else if let homeNav = tabBarController.viewControllers?.first as? UINavigationController {
            // Final fallback to home navigation
            homeNav.pushViewController(profileVC, animated: true)
        }
    }

    func switchToHomeTab() {
        tabBarController.selectedIndex = 0
    }

    func switchToStoriesTab() {
        tabBarController.selectedIndex = 3
    }

    func getCurrentNickname() -> String? {
        return homeViewController?.getCurrentNickname()
    }

    /// 계정 전환 시 홈 상태 초기화 (이전 사용자의 hobbyId 제거)
    func resetHomeState() {
        homeViewController?.resetForAccountSwitch()
    }
}
