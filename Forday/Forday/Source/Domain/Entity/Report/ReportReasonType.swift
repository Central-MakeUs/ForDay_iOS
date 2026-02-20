//
//  ReportReasonType.swift
//  Forday
//
//  Created by Subeen on 2/21/26.
//

import Foundation

/// 신고 사유 타입
enum ReportReasonType: String, CaseIterable {
    case spam = "SPAM"
    case hateSpeech = "HATE_SPEECH"
    case sexualContent = "SEXUAL_CONTENT"
    case violentContent = "VIOLENT_CONTENT"
    case privacyViolation = "PRIVACY_VIOLATION"
    case copyrightViolation = "COPYRIGHT_VIOLATION"
    case falseInfo = "FALSE_INFO"
    case scam = "SCAM"
    case other = "OTHER"

    /// 사용자에게 표시되는 이름
    var displayName: String {
        switch self {
        case .spam:
            return "스팸 · 광고"
        case .hateSpeech:
            return "욕설 · 혐오 발언"
        case .sexualContent:
            return "성적인 콘텐츠"
        case .violentContent:
            return "폭력적 · 위험한 콘텐츠"
        case .privacyViolation:
            return "개인정보 침해"
        case .copyrightViolation:
            return "저작권 침해"
        case .falseInfo:
            return "허위 정보"
        case .scam:
            return "사기 · 사칭"
        case .other:
            return "기타"
        }
    }
}
