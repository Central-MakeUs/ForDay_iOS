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
    case fetchRecordDetail(recordId: Int, context: ActivityDetailContext?)
    case updateRecord(recordId: Int, request: DTO.UpdateRecordRequest)
    case deleteRecord(recordId: Int)
    case addReaction(recordId: Int, reactionType: ReactionType)
    case deleteReaction(recordId: Int, reactionType: ReactionType)
    case fetchReactionUsers(recordId: Int, reactionType: ReactionType, lastUserId: String?, size: Int)
    case addScrap(recordId: Int)
    case deleteScrap(recordId: Int)
    case reportRecord(recordId: Int, request: DTO.ReportRecordRequest)
}

extension RecordsTarget: BaseTargetType {

    var path: String {
        switch self {
        case .fetchRecordDetail(let recordId, _):
            return RecordsAPI.fetchRecordDetail(recordId).endpoint
        case .updateRecord(let recordId, _):
            return RecordsAPI.updateRecord(recordId: recordId).endpoint
        case .deleteRecord(let recordId):
            return RecordsAPI.deleteRecord(recordId).endpoint
        case .addReaction(let recordId, _):
            return RecordsAPI.addReaction(recordId: recordId).endpoint
        case .deleteReaction(let recordId, _):
            return RecordsAPI.deleteReaction(recordId: recordId).endpoint
        case .fetchReactionUsers(let recordId, _, _, _):
            return RecordsAPI.fetchReactionUsers(recordId: recordId).endpoint
        case .addScrap(let recordId):
            return RecordsAPI.addScrap(recordId: recordId).endpoint
        case .deleteScrap(let recordId):
            return RecordsAPI.deleteScrap(recordId: recordId).endpoint
        case .reportRecord(let recordId, _):
            return RecordsAPI.reportRecord(recordId: recordId).endpoint
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchRecordDetail:
            return .get
        case .updateRecord:
            return .put
        case .deleteRecord:
            return .delete
        case .addReaction:
            return .post
        case .deleteReaction:
            return .delete
        case .fetchReactionUsers:
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
        case .fetchRecordDetail(_, let context):
            if let context = context {
                return .requestParameters(
                    parameters: context.toQueryParameters(),
                    encoding: URLEncoding.queryString
                )
            } else {
                return .requestPlain
            }
        case .updateRecord(_, let request):
            return .requestJSONEncodable(request)
        case .deleteRecord:
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
        case .addScrap:
            return .requestPlain
        case .deleteScrap:
            return .requestPlain
        case .reportRecord(_, let request):
            return .requestJSONEncodable(request)
        }
    }

    var headers: [String : String]? {
        return APIConstants.baseHeader
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
