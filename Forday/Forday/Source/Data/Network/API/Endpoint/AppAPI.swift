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
    case deleteImage              /// S3 임시 이미지 삭제
    case fetchAlarm               /// 알림 모아보기
    case fetchVersionPolicy       /// 앱 버전 정책 조회

    var endpoint: String {
        switch self {
        case .fetchAppMetadata:
            return "/app/metadata"

        case .fetchPresignedUrl:
            return "/app/presign"

        case .deleteImage:
            return "/app/images/temp"

        case .fetchAlarm:
            return ""

        case .fetchVersionPolicy:
            return "/app/version-policy"
        }
    }
}
