//
//  HobbyInfoMapper.swift
//  Forday
//
//  Created by Subeen on 7/8/26.
//

import Foundation

/// 취미 이름을 hobbyInfoId로 매핑하는 유틸리티
/// - Note: 기본 제공 취미는 고정된 hobbyInfoId를 가지며, 커스텀 취미는 nil 반환
enum HobbyInfoMapper {

    /// 취미 이름 → hobbyInfoId 매핑 (기본 제공 취미만)
    private static let hobbyInfoMapping: [String: Int] = [
        "그림 그리기": 1,
        "헬스": 2,
        "독서": 3,
        "음악 듣기": 4,
        "러닝": 5,
        "요리": 6,
        "카페 탐방": 7,
        "영화 보기": 8,
        "사진 촬영": 9,
        "글쓰기": 10
    ]

    /// 취미 이름으로 hobbyInfoId를 조회합니다.
    /// - Parameter hobbyName: 취미 이름
    /// - Returns: 기본 제공 취미면 hobbyInfoId, 커스텀 취미면 nil
    static func getHobbyInfoId(for hobbyName: String) -> Int? {
        return hobbyInfoMapping[hobbyName]
    }

    /// 취미가 기본 제공 취미인지 확인합니다.
    /// - Parameter hobbyName: 취미 이름
    /// - Returns: 기본 제공 취미 여부
    static func isDefaultHobby(_ hobbyName: String) -> Bool {
        return hobbyInfoMapping[hobbyName] != nil
    }
}
