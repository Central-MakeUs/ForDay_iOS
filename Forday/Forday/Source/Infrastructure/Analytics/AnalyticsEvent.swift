//
//  AnalyticsEvent.swift
//  Forday
//
//  Created by Subeen on 3/5/26.
//

import Foundation

/// Firebase Analytics 이벤트 정의
enum AnalyticsEvent {

    // MARK: - 로그인
    /// 로그인 화면 진입
    case loginScreen
    /// 카카오 로그인 클릭
    case kakaoLoginClick
    /// 애플 로그인 클릭 (iOS 전용)
    case appleLoginClick
    /// 게스트 모드 클릭
    case guestModeClick

    // MARK: - 취미 선택
    /// 취미 선택 화면 진입
    case selectHobbyScreen
    /// 취미 카드 선택 (파라미터: 취미명)
    case selectedHobbyCard(name: String)
    /// 직접 입력 취미 버튼 클릭
    case clickDirectInputHobbyBtn
    /// 사용자 커스텀 취미 입력 (파라미터: 입력 텍스트)
    case hobbyUserCustom(text: String)

    // MARK: - 시간 선택
    /// 취미 시간 선택 화면 진입
    case viewHobbyTimeSelectionScreen
    /// 시간 선택 (파라미터: 분)
    case selectedTime(minutes: Int)
    /// 취미 시간 선택 뒤로가기
    case hobbyTimeSelectionBackClick

    // MARK: - 목적 선택
    /// 취미 목적 선택 화면 진입
    case hobbyPurposeSelectionScreen
    /// 취미 목적 선택 뒤로가기
    case hobbyPurposeSelectionScreenBackClick
    /// 커스텀 목적 버튼 클릭
    case hobbyPurposeSelectionScreenCustomPurposeClick
    /// 사용자 커스텀 목적 입력 (파라미터: 입력 텍스트)
    case userCustomPurpose(text: String)
    /// 목적 선택 완료 (파라미터: 선택된 목적)
    case selectedPurpose(purpose: String)

    // MARK: - 빈도 선택
    /// 취미 빈도 설정 화면 진입
    case hobbyInfoFrequencyEntry
    /// 취미 빈도 뒤로가기
    case hobbyFrequencyBackClick
    /// 주간 횟수 선택 (파라미터: 횟수)
    case hobbyWeeklyCount(count: Int)

    // MARK: - 여정 날짜 선택
    /// 취미 여정 날짜 화면 진입
    case hobbyJourneyDateScreen
    /// 취미 여정 날짜 뒤로가기
    case hobbyJourneyDateScreenBackClick
    /// 온보딩 완료
    case onboardingSuccess
    /// 여정 기간 선택 (파라미터: 모드)
    case selectedJourneyDate(mode: String)

    // MARK: - 닉네임
    /// 닉네임 입력 화면 진입
    case nicknameDirectInputScreen
    /// 닉네임 등록 클릭
    case nicknameRegisterClick
    /// 입력된 닉네임 (파라미터: 닉네임)
    case currentInputNickname(nickname: String)

    // MARK: - 홈
    /// 홈 화면 진입
    case homeScreen
    /// 취미 활동 추가 버튼 클릭
    case homeScreenClickAddHobbyActivityBtn
    /// 취미 활동 목록 보기 클릭
    case homeScreenClickShowHobbyActivityListBtn
    /// 빈 스티커 클릭
    case homeScreenClickEmptySticker

    // MARK: - 소식
    /// 소식 화면 진입
    case sosikScreen

    // MARK: - 활동 입력 / AI 추천
    /// AI 추천 보기 클릭
    case hobbyInputViewAIRecommendationsClick
    /// 최종 취미 활동 확정 (파라미터: 활동명)
    case finalHobbyActivity(activityName: String)
    /// 취미 생성 클릭
    case createHobbyClick
    /// AI 추천 루틴 화면 진입
    case aiRecommendHobbyRoutineScreen
    /// AI 추천 루틴 뒤로가기
    case aiRecommendHobbyRoutineScreenBackBtnClick
    /// AI 추천 루틴 선택 (파라미터: 활동내용)
    case aiRecommendSelectedRoutine(content: String)
    /// AI 활동 재시도 (파라미터: 횟수)
    case aiActivityRetryClick(count: Int)
    /// AI 추천 다음 클릭
    case clickAIRecommendationNext
    /// AI 추천 화면 로드 (파라미터: 취미명, 추천_개수)
    case aiRecommendationShown(hobbyName: String, recommendationCount: Int)
    /// 추천 활동 클릭 (파라미터: 취미명, 활동명, 위치)
    case aiRecommendationClicked(hobbyName: String, activityName: String, position: Int)

    // MARK: - 기록 / 취미 수정
    /// 루틴 기록 화면 진입
    case recordRoutineScreen
    /// 취미 수정 화면 진입
    case modifyHobbyScreen
    /// 활동 추가 버튼 클릭 (파라미터: 진입점, 취미명)
    case activityAddEntryClicked(entryPoint: ActivityEntryPoint, hobbyName: String)
    /// 활동 추가 완료 (파라미터: 진입점, 출처, 취미명, 활동명)
    case activityAdded(entryPoint: ActivityEntryPoint, source: ActivitySource, hobbyName: String, activityName: String)
    /// 기록 작성 시작 (파라미터: 진입점, 취미명, 활동명)
    case recordEntryClicked(entryPoint: RecordEntryPoint, hobbyName: String?, activityName: String?)
    /// 기록 작성 완료 (파라미터: 진입점, 취미명, 활동명, 사진_유무, 메모_유무)
    case recordCreated(entryPoint: RecordEntryPoint, hobbyName: String, activityName: String, hasPhoto: Bool, hasMemo: Bool)

    // MARK: - Event Name & Parameters

    /// Firebase 이벤트 이름 (한글 적용)
    var name: String {
        switch self {
        case .loginScreen: return "로그인_화면_진입"
        case .kakaoLoginClick: return "카카오_로그인_클릭"
        case .appleLoginClick: return "애플_로그인_클릭"
        case .guestModeClick: return "게스트_모드_클릭"

        case .selectHobbyScreen: return "취미_선택_화면_진입"
        case .selectedHobbyCard: return "취미_카드_선택"
        case .clickDirectInputHobbyBtn: return "직접_입력_취미_버튼_클릭"
        case .hobbyUserCustom: return "사용자_커스텀_취미_입력"

        case .viewHobbyTimeSelectionScreen: return "취미_시간_선택_화면_진입"
        case .selectedTime: return "시간_선택"
        case .hobbyTimeSelectionBackClick: return "취미_시간_선택_뒤로가기"

        case .hobbyPurposeSelectionScreen: return "취미_목적_선택_화면_진입"
        case .hobbyPurposeSelectionScreenBackClick: return "취미_목적_선택_뒤로가기"
        case .hobbyPurposeSelectionScreenCustomPurposeClick: return "커스텀_목적_버튼_클릭"
        case .userCustomPurpose: return "사용자_커스텀_목적_입력"
        case .selectedPurpose: return "목적_선택_완료"

        case .hobbyInfoFrequencyEntry: return "취미_빈도_설정_화면_진입"
        case .hobbyFrequencyBackClick: return "취미_빈도_뒤로가기"
        case .hobbyWeeklyCount: return "주간_횟수_선택"

        case .hobbyJourneyDateScreen: return "취미_여정_날짜_화면_진입"
        case .hobbyJourneyDateScreenBackClick: return "취미_여정_날짜_뒤로가기"
        case .onboardingSuccess: return "온보딩_완료"
        case .selectedJourneyDate: return "여정_기간_선택"

        case .nicknameDirectInputScreen: return "닉네임_입력_화면_진입"
        case .nicknameRegisterClick: return "닉네임_등록_클릭"
        case .currentInputNickname: return "입력된_닉네임"

        case .homeScreen: return "홈_화면_진입"
        case .homeScreenClickAddHobbyActivityBtn: return "취미_활동_추가_버튼_클릭"
        case .homeScreenClickShowHobbyActivityListBtn: return "취미_활동_목록_보기_클릭"
        case .homeScreenClickEmptySticker: return "빈_스티커_클릭"

        case .sosikScreen: return "소식_화면_진입"

        case .hobbyInputViewAIRecommendationsClick: return "AI_추천_보기_클릭"
        case .finalHobbyActivity: return "최종_취미_활동_확정"
        case .createHobbyClick: return "취미_생성_클릭"
        case .aiRecommendHobbyRoutineScreen: return "AI_추천_루틴_화면_진입"
        case .aiRecommendHobbyRoutineScreenBackBtnClick: return "AI_추천_루틴_뒤로가기"
        case .aiRecommendSelectedRoutine: return "AI_추천_루틴_선택"
        case .aiActivityRetryClick: return "AI_활동_재시도"
        case .clickAIRecommendationNext: return "AI_추천_다음_클릭"
        case .aiRecommendationShown: return "AI_추천_화면_로드"
        case .aiRecommendationClicked: return "추천_활동_클릭"

        case .recordRoutineScreen: return "루틴_기록_화면_진입"
        case .modifyHobbyScreen: return "취미_수정_화면_진입"
        case .activityAddEntryClicked: return "활동_추가_버튼_클릭"
        case .activityAdded: return "활동_추가_완료"
        case .recordEntryClicked: return "기록_작성_시작"
        case .recordCreated: return "기록_작성_완료"
        }
    }

    /// Firebase 이벤트 파라미터 (한글 키 적용)
    var parameters: [String: Any]? {
        switch self {
        case .selectedHobbyCard(let name):
            return ["취미명": name]

        case .hobbyUserCustom(let text):
            return ["입력_텍스트": text]

        case .selectedTime(let minutes):
            return ["분": minutes]

        case .userCustomPurpose(let text):
            return ["입력_텍스트": text]

        case .selectedPurpose(let purpose):
            return ["선택된_목적": purpose]

        case .hobbyWeeklyCount(let count):
            return ["횟수": count]

        case .selectedJourneyDate(let mode):
            return ["모드": mode]

        case .currentInputNickname(let nickname):
            return ["닉네임": nickname]

        case .finalHobbyActivity(let activityName):
            return ["활동명": activityName]

        case .aiRecommendSelectedRoutine(let content):
            return ["활동내용": content]

        case .aiActivityRetryClick(let count):
            return ["횟수": count]

        case .aiRecommendationShown(let hobbyName, let recommendationCount):
            return [
                "취미명": hobbyName,
                "추천_개수": recommendationCount
            ]

        case .aiRecommendationClicked(let hobbyName, let activityName, let position):
            return [
                "취미명": hobbyName,
                "활동명": activityName,
                "위치": position
            ]

        case .activityAddEntryClicked(let entryPoint, let hobbyName):
            return [
                "진입점": entryPoint.rawValue,
                "취미명": hobbyName
            ]

        case .activityAdded(let entryPoint, let source, let hobbyName, let activityName):
            return [
                "진입점": entryPoint.rawValue,
                "출처": source.rawValue,
                "취미명": hobbyName,
                "활동명": activityName
            ]

        case .recordEntryClicked(let entryPoint, let hobbyName, let activityName):
            var params: [String: Any] = ["진입점": entryPoint.rawValue]
            if let hobbyName = hobbyName { params["취미명"] = hobbyName }
            if let activityName = activityName { params["활동명"] = activityName }
            return params

        case .recordCreated(let entryPoint, let hobbyName, let activityName, let hasPhoto, let hasMemo):
            return [
                "진입점": entryPoint.rawValue,
                "취미명": hobbyName,
                "활동명": activityName,
                "사진_유무": hasPhoto,
                "메모_유무": hasMemo
            ]

        default:
            return nil
        }
    }
}

// MARK: - Supporting Types

/// 활동 추가 진입점
enum ActivityEntryPoint: String {
    case homeFab = "홈_FAB"
    case aiBanner = "AI_배너"
    case activityListPlus = "활동_목록_추가"
}

/// 활동 소스
enum ActivitySource: String {
    case aiRecommendation = "AI_추천"
    case manual = "직접_입력"
}

/// 기록 작성 진입점
enum RecordEntryPoint: String {
    case gnbRecord = "GNB_기록"
    case stickerCta = "스티커_CTA"
    case emptySticker = "빈_스티커"
}