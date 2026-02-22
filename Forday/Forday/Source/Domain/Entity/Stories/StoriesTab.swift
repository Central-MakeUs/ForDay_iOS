//
//  StoriesTab.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

struct StoriesTab {
    let hobbyId: Int?  // nil이면 "전체" 탭
    let hobbyName: String
    let currentHobby: Bool

    /// 전체 탭 생성
    static var allTab: StoriesTab {
        StoriesTab(hobbyId: nil, hobbyName: "전체", currentHobby: false)
    }

    /// 전체 탭인지 확인
    var isAllTab: Bool {
        hobbyId == nil
    }
}
