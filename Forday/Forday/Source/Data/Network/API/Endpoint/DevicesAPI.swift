//
//  DevicesAPI.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

enum DevicesAPI {
    case enrollDevice       /// 알림 기기 등록
    case deleteDevice       /// 알림 기기 등록 해제
    
    var endpoint: String {
        switch self {
        case .enrollDevice,
                .deleteDevice:
            return "/devices"
        }
    }
}
