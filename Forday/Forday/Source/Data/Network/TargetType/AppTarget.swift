//
//  AppTarget.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation
import Moya
import Alamofire

enum AppTarget {
    case fetchAppMetadata
    case fetchPresignedUrl(request: DTO.PresignedUrlRequest)
    case deleteImage(request: DTO.DeleteImageRequest)
    case fetchVersionPolicy(platform: String, appVersion: String, build: Int)
}

extension AppTarget: BaseTargetType {
    
    var baseURL: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    var path: String {
        switch self {
        case .fetchAppMetadata:
            return AppAPI.fetchAppMetadata.endpoint
        case .fetchPresignedUrl:
            return AppAPI.fetchPresignedUrl.endpoint
        case .deleteImage:
            return AppAPI.deleteImage.endpoint
        case .fetchVersionPolicy:
            return AppAPI.fetchVersionPolicy.endpoint
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchAppMetadata:
            return .get
        case .fetchPresignedUrl:
            return .post
        case .deleteImage:
            return .delete
        case .fetchVersionPolicy:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchAppMetadata:
            return .requestPlain
        case .fetchPresignedUrl(let request):
            return .requestJSONEncodable(request)
        case .deleteImage(let request):
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            return .requestCustomJSONEncodable(request, encoder: encoder)
        case .fetchVersionPolicy(let platform, let appVersion, let build):
            return .requestParameters(
                parameters: [
                    "platform": platform,
                    "appVersion": appVersion,
                    "build": build
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
}
