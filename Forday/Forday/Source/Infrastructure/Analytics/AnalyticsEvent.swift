//
//  AnalyticsEvent.swift
//  Forday
//
//  Created by Subeen on 3/5/26.
//

import Foundation

/// Firebase Analytics 이벤트 정의
///
/// # 사용 예시
///
/// ```swift
/// // 화면 진입 이벤트 (파라미터 없음)
/// FirebaseAnalyticsService.shared.log(.loginScreen)
///
/// // 선택 이벤트 (파라미터 포함)
/// FirebaseAnalyticsService.shared.log(.selectedHobbyCard(id: "cooking"))
/// FirebaseAnalyticsService.shared.log(.selectedTime(minutes: 30))
///
/// // AI 추천 이벤트
/// FirebaseAnalyticsService.shared.log(.aiRecommendationShown(
///     hobbyName: "요리",
///     recommendationCount: 5
/// ))
///
/// // 활동 추가 이벤트
/// FirebaseAnalyticsService.shared.log(.activityAdded(
///     entryPoint: .homeFab,
///     source: .manual,
///     hobbyName: "요리",
///     activityName: "파스타 만들기"
/// ))
///
/// // 기록 작성 이벤트
/// FirebaseAnalyticsService.shared.log(.recordCreated(
///     entryPoint: .stickerCta,
///     hobbyName: "요리",
///     activityName: "파스타 만들기",
///     hasPhoto: true,
///     hasMemo: true
/// ))
/// ```
enum AnalyticsEvent {

    // MARK: - Phase 1: 로그인
    case loginScreen
    case guestModeClick

    // MARK: - Phase 2: 온보딩 Flow
    case selectHobbyScreen
    case clickDirectInputHobbyBtn
    case selectedHobbyCard(id: String)
    case viewHobbyTimeSelectionScreen
    case selectedTime(minutes: Int)
    case hobbyInfoFrequencyEntry
    case hobbyWeeklyCount(count: Int)
    case hobbyJourneyDateScreen
    case selectedJourneyDate(mode: String) // "66일" or "기간 미지정"
    case onboardingSuccess

    // MARK: - Phase 3: 닉네임 설정 및 홈
    case nicknameDirectInputScreen
    case currentInputNickname(name: String)
    case nicknameRegisterClick
    case homeScreen
    case homeScreenClickAddHobbyActivityBtn

    // MARK: - Phase 4: 취미 생성 및 AI 추천
    case hobbyInputViewAIRecommendationsClick
    case aiRecommendHobbyRoutineScreen
    case clickAIRecommendationNext
    case createHobbyClick

    // MARK: - 상세 스펙: AI 추천
    case aiRecommendationShown(hobbyName: String, recommendationCount: Int)
    case aiRecommendationClicked(hobbyName: String, activityName: String, position: Int)

    // MARK: - 상세 스펙: 활동 추가
    case activityAddEntryClicked(entryPoint: ActivityEntryPoint, hobbyName: String)
    case activityAdded(entryPoint: ActivityEntryPoint, source: ActivitySource, hobbyName: String, activityName: String)

    // MARK: - 상세 스펙: 기록 작성
    case recordEntryClicked(entryPoint: RecordEntryPoint, hobbyName: String?, activityName: String?)
    case recordCreated(entryPoint: RecordEntryPoint, hobbyName: String, activityName: String, hasPhoto: Bool, hasMemo: Bool)

    // MARK: - Event Name & Parameters

    /// Firebase 이벤트 이름
    var name: String {
        switch self {
        // Phase 1
        case .loginScreen: return "login_screen"
        case .guestModeClick: return "guest_mode_click"

        // Phase 2
        case .selectHobbyScreen: return "select_hobby_screen"
        case .clickDirectInputHobbyBtn: return "click_direct_input_hobby_btn"
        case .selectedHobbyCard(let id): return "selected_hobby_card_\(id)"
        case .viewHobbyTimeSelectionScreen: return "view_hobby_time_selection_screen"
        case .selectedTime(let minutes): return "selected_time_\(minutes)"
        case .hobbyInfoFrequencyEntry: return "hobby_info_frequency_entry"
        case .hobbyWeeklyCount(let count): return "hobby_weekly_count_\(count)"
        case .hobbyJourneyDateScreen: return "hobby_journey_date_screen"
        case .selectedJourneyDate(let mode): return "selected_journey_date_\(mode)"
        case .onboardingSuccess: return "onboarding_success"

        // Phase 3
        case .nicknameDirectInputScreen: return "nickname_direct_input_screen"
        case .currentInputNickname(let name): return "current_input_nickname_\(name)"
        case .nicknameRegisterClick: return "nickname_register_click"
        case .homeScreen: return "home_screen"
        case .homeScreenClickAddHobbyActivityBtn: return "home_screen_click_add_hobby_activity_btn"

        // Phase 4
        case .hobbyInputViewAIRecommendationsClick: return "hobby_input_view_ai_recommendations_click"
        case .aiRecommendHobbyRoutineScreen: return "ai_recommend_hobby_routine_screen"
        case .clickAIRecommendationNext: return "click_ai_recommendation_next"
        case .createHobbyClick: return "create_hobby_click"

        // 상세 스펙
        case .aiRecommendationShown: return "ai_recommendation_shown"
        case .aiRecommendationClicked: return "ai_recommendation_clicked"
        case .activityAddEntryClicked: return "activity_add_entry_clicked"
        case .activityAdded: return "activity_added"
        case .recordEntryClicked: return "record_entry_clicked"
        case .recordCreated: return "record_created"
        }
    }

    /// Firebase 이벤트 파라미터
    var parameters: [String: Any]? {
        switch self {
        case .aiRecommendationShown(let hobbyName, let recommendationCount):
            return [
                "hobby_name": hobbyName,
                "recommendation_count": recommendationCount
            ]

        case .aiRecommendationClicked(let hobbyName, let activityName, let position):
            return [
                "hobby_name": hobbyName,
                "activity_name": activityName,
                "position": position
            ]

        case .activityAddEntryClicked(let entryPoint, let hobbyName):
            return [
                "entry_point": entryPoint.rawValue,
                "hobby_name": hobbyName
            ]

        case .activityAdded(let entryPoint, let source, let hobbyName, let activityName):
            return [
                "entry_point": entryPoint.rawValue,
                "source": source.rawValue,
                "hobby_name": hobbyName,
                "activity_name": activityName
            ]

        case .recordEntryClicked(let entryPoint, let hobbyName, let activityName):
            var params: [String: Any] = ["entry_point": entryPoint.rawValue]
            if let hobbyName = hobbyName { params["hobby_name"] = hobbyName }
            if let activityName = activityName { params["activity_name"] = activityName }
            return params

        case .recordCreated(let entryPoint, let hobbyName, let activityName, let hasPhoto, let hasMemo):
            return [
                "entry_point": entryPoint.rawValue,
                "hobby_name": hobbyName,
                "activity_name": activityName,
                "has_photo": hasPhoto,
                "has_memo": hasMemo
            ]

        default:
            return nil
        }
    }
}

// MARK: - Supporting Types

/// 활동 추가 진입점
enum ActivityEntryPoint: String {
    case homeFab = "home_fab"
    case aiBanner = "ai_banner"
    case activityListPlus = "activity_list_plus"
}

/// 활동 소스
enum ActivitySource: String {
    case aiRecommendation = "ai_recommendation"
    case manual = "manual"
}

/// 기록 작성 진입점
enum RecordEntryPoint: String {
    case gnbRecord = "gnb_record"
    case stickerCta = "sticker_cta"
    case emptySticker = "empty_sticker"
}
