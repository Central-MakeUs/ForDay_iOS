//
//  AppAPI.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Moya

enum AppAPI {
    case fetchAppMetadata         /// 앱 리소스 다운로드
    case fetchPresignedUrl        /// presigned url 발급
    case fetchAlarm               /// 알림 모아보기
}
