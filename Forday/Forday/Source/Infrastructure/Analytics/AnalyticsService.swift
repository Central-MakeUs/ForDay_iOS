//
//  AnalyticsService.swift
//  Forday
//
//  Created by Subeen on 3/5/26.
//

import Foundation

/// Analytics 서비스 프로토콜
protocol AnalyticsService {
    /// 이벤트 전송
    func log(_ event: AnalyticsEvent)

    /// 사용자 속성 설정
    func setUserProperty(value: String?, forName name: String)

    /// 사용자 ID 설정
    func setUserID(_ userID: String?)
}
