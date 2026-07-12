//
//  RecordsTarget.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation
import Moya
import Alamofire

enum RecordsTarget {
    case fetchRecordDetail(recordId: Int)                                   // v1: 단일 조회
    case fetchRecordDetailV2(recordId: Int, context: ActivityDetailContext) // v2: 페이징 조회 (context 필수)
    case fetchRecordDetailV3(recordId: Int, context: ActivityDetailContext?) // v3: 다중 이미지
    case updateRecord(recordId: Int, request: DTO.UpdateRecordRequest)
    case updateRecordV2(recordId: Int, request: DTO.UpdateRecordV2Request)
    case deleteRecord(recordId: Int)
    case deleteRecordV2(recordId: Int)
    case addReaction(recordId: Int, reactionType: ReactionType)
    case deleteReaction(recordId: Int, reactionType: ReactionType)
    case fetchReactionUsers(recordId: Int, reactionType: ReactionType, lastUserId: String?, size: Int)
    case fetchReactionSummary(recordId: Int, size: Int)
    case fetchReactionTabData(recordId: Int, reactionType: ReactionType?, lastReactionId: Int?, size: Int)
    case addScrap(recordId: Int)
    case deleteScrap(recordId: Int)
    case reportRecord(recordId: Int, request: DTO.ReportRecordRequest)
    case fetchKeyboardKeywords(hobbyInfoId: Int)
}

extension RecordsTarget: BaseTargetType {

    var path: String {
        switch self {
        case .fetchRecordDetail(let recordId):
            return RecordsAPI.fetchRecordDetail(recordId).endpoint
        case .fetchRecordDetailV2(let recordId, _):
            return RecordsAPI.fetchRecordDetailV2(recordId).endpoint
        case .fetchRecordDetailV3(let recordId, _):
            return RecordsAPI.fetchRecordDetailV3(recordId).endpoint
        case .updateRecord(let recordId, _):
            return RecordsAPI.updateRecord(recordId: recordId).endpoint
        case .updateRecordV2(let recordId, _):
            return RecordsAPI.updateRecordV2(recordId: recordId).endpoint
        case .deleteRecord(let recordId):
            return RecordsAPI.deleteRecord(recordId).endpoint
        case .deleteRecordV2(let recordId):
            return RecordsAPI.deleteRecordV2(recordId).endpoint
        case .addReaction(let recordId, _):
            return RecordsAPI.addReaction(recordId: recordId).endpoint
        case .deleteReaction(let recordId, _):
            return RecordsAPI.deleteReaction(recordId: recordId).endpoint
        case .fetchReactionUsers(let recordId, _, _, _):
            return RecordsAPI.fetchReactionUsers(recordId: recordId).endpoint
        case .fetchReactionSummary(let recordId, _):
            return RecordsAPI.fetchReactionSummary(recordId: recordId).endpoint
        case .fetchReactionTabData(let recordId, _, _, _):
            return RecordsAPI.fetchReactionTabData(recordId: recordId).endpoint
        case .addScrap(let recordId):
            return RecordsAPI.addScrap(recordId: recordId).endpoint
        case .deleteScrap(let recordId):
            return RecordsAPI.deleteScrap(recordId: recordId).endpoint
        case .reportRecord(let recordId, _):
            return RecordsAPI.reportRecord(recordId: recordId).endpoint
        case .fetchKeyboardKeywords:
            return RecordsAPI.fetchKeyboardKeywords.endpoint
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchRecordDetail, .fetchRecordDetailV2, .fetchRecordDetailV3, .fetchKeyboardKeywords:
            return .get
        case .updateRecord, .updateRecordV2:
            return .put
        case .deleteRecord, .deleteRecordV2:
            return .delete
        case .addReaction:
            return .post
        case .deleteReaction:
            return .delete
        case .fetchReactionUsers, .fetchReactionSummary, .fetchReactionTabData:
            return .get
        case .addScrap:
            return .post
        case .deleteScrap:
            return .delete
        case .reportRecord:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .fetchRecordDetail:
            return .requestPlain
        case .fetchRecordDetailV3(_, let context):
            if let context = context {
                return .requestParameters(
                    parameters: context.toQueryParameters(),
                    encoding: URLEncoding.queryString
                )
            }
            return .requestPlain
        case .fetchRecordDetailV2(_, let context):
            return .requestParameters(
                parameters: context.toQueryParameters(),
                encoding: URLEncoding.queryString
            )
        case .updateRecord(_, let request):
            return .requestJSONEncodable(request)
        case .updateRecordV2(_, let request):
            return .requestJSONEncodable(request)
        case .deleteRecord, .deleteRecordV2:
            return .requestPlain
        case .addReaction(_, let reactionType):
            let request = DTO.AddReactionRequest(reactionType: reactionType.rawValue)
            return .requestJSONEncodable(request)
        case .deleteReaction(_, let reactionType):
            return .requestParameters(
                parameters: ["reactionType": reactionType.rawValue],
                encoding: URLEncoding.queryString
            )
        case .fetchReactionUsers(_, let reactionType, let lastUserId, let size):
            var parameters: [String: Any] = [
                "reactionType": reactionType.rawValue,
                "size": size
            ]

            if let lastUserId = lastUserId {
                parameters["lastUserId"] = lastUserId
            }

            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        case .fetchReactionSummary(_, let size):
            return .requestParameters(
                parameters: ["size": size],
                encoding: URLEncoding.queryString
            )
        case .fetchReactionTabData(_, let reactionType, let lastReactionId, let size):
            var parameters: [String: Any] = [
                "size": size
            ]

            if let reactionType = reactionType {
                parameters["type"] = reactionType.rawValue
            }

            if let lastReactionId = lastReactionId {
                parameters["lastReactionId"] = lastReactionId
            }

            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        case .addScrap:
            return .requestPlain
        case .deleteScrap:
            return .requestPlain
        case .reportRecord(_, let request):
            return .requestJSONEncodable(request)
        case .fetchKeyboardKeywords(let hobbyInfoId):
            return .requestParameters(
                parameters: ["hobbyInfoId": hobbyInfoId],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String : String]? {
        return APIConstants.baseHeader
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
