//
//  HobbiesAPI.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation

enum HobbiesAPI {
    case createHobby                    /// 취미 생성 (v1)
    case createHobbyV2                  /// 취미 생성 (v2 - 여러 개 한번에)
    case fetchHobbyInfoRecheck          /// 취미 정보 재조회 (취미 추가 시)
    case fetchHomeInfo                  /// 홈 진입 취미 정보 조회
    case fetchHomeStickerInfo           /// 홈 스티커판 조회
    case fetchOthersActivities          /// [Version1] 다른 포비들의 활동 조회 (AI 기반)
    case fetchAIRecommendations         /// AI 취미 활동 추천
    case fetchAIActivityItems           /// AI 추천 활동 리스트 조회

    case fetchHobbyChips                /// 활동 기록 - 취미 칩 목록 조회
    case fetchActivityList(Int)         /// 활동 리스트 조회
    case fetchActivityDropdownList(Int) /// (드롭다운용) 특정 취미의 활동 목록 조회 상위 5개
    case createActivities(Int)          /// 취미 활동 추가하기
    case updateActivity(Int)            /// 활동 수정하기
    case deleteActivity(Int)            /// 활동 삭제하기
    case createActivityRecord(Int)      /// 취미 활동 기록하기

    case fetchHobbySettings             /// 내 취미 관리 페이지 조회
    case updateHobby(Int)               /// 온보딩 중 취미 수정 (nicknameSet: false && onboardingCompleted: true)
    case updateHobbyTime(Int)           /// 취미 시간 변경
    case updateExecutionCount(Int)      /// 실행 횟수 변경
    case updateGoalDays(Int)            /// 목표 기간 변경
    case updateHobbyStatus(Int)         /// 취미 보관/꺼내기
    case updateCoverImage               /// 취미 대표사진 변경
    
    var endpoint: String {
        switch self {
        case .createHobby:
            return "/hobbies/create"

        case .createHobbyV2:
            return "/api/v2/hobbies/create"

        case .fetchHobbyInfoRecheck:
            return "/hobbies/info/re-check"

        case .fetchHomeInfo:
            return "/api/v2/hobbies/home"
            
        case .fetchHomeStickerInfo:
            return "/hobbies/stickers"

        case .fetchOthersActivities:
            return "/hobbies/activities/others/v1"

        case .fetchAIRecommendations:
            return "/hobbies/activities/ai/recommend"

        case .fetchAIActivityItems:
            return "/activities/ai-recommend/items"

        case .fetchHobbyChips:
            return "/hobbies/chips"

        case .fetchActivityList(let hobbyId):
            return "/hobbies/\(hobbyId)/activities/list"
            
        case .fetchActivityDropdownList(let hobbyId):
            return "/hobbies/\(hobbyId)/activities"
            
        case .createActivities(let hobbyId):
            return "/hobbies/\(hobbyId)/activities"
        
        case .updateActivity(let activityId):
            return "/activities/\(activityId)"

        case .deleteActivity(let activityId):
            return "/activities/\(activityId)"

        case .createActivityRecord(let activityId):
            return "/hobbies/activities/\(activityId)/record"

        case .fetchHobbySettings:
            return "/hobbies/setting"

        case .updateHobby(let hobbyId):
            return "/hobbies/\(hobbyId)/update"

        case .updateHobbyTime(let hobbyId):
            return "/hobbies/\(hobbyId)/time"

        case .updateExecutionCount(let hobbyId):
            return "/hobbies/\(hobbyId)/execution-count"

        case .updateGoalDays(let hobbyId):
            return "/hobbies/\(hobbyId)/goal-days"

        case .updateHobbyStatus(let hobbyId):
            return "/hobbies/\(hobbyId)/status"

        case .updateCoverImage:
            return "/hobbies/cover-image"
        }
    }
}
