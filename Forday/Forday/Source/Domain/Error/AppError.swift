//
//  AppError.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

enum AppError: Error {
    case network(NetworkError)
    case server(ServerError)
    case auth(AuthError)
    case decoding(DecodingError)
    case validation(String)
    case unknown(Error)

    var userMessage: String {
        switch self {
        case .network(let error):
            return error.userMessage
        case .server(let error):
            return error.message
        case .auth(let error):
            return error.userMessage
        case .decoding:
            return "데이터를 불러오는 중 문제가 발생했습니다."
        case .validation(let message):
            return message
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Auth Errors

enum AuthError: Error {
    case unauthorized
    case tokenExpired
    case loginExpired
    case fcmTokenNotAvailable

    var userMessage: String {
        switch self {
        case .unauthorized:
            return "인증에 실패했습니다."
        case .tokenExpired:
            return "세션이 만료되었습니다."
        case .loginExpired:
            return "로그인이 만료되었습니다.\n다시 로그인해주세요."
        case .fcmTokenNotAvailable:
            return "알림 설정을 완료하는 중입니다.\n잠시 후 다시 시도해주세요."
        }
    }
}

// MARK: - Network Errors

enum NetworkError: Error {
    case noInternet
    case timeout
    case cancelled
    case unknown

    var userMessage: String {
        switch self {
        case .noInternet:
            return "인터넷 연결을 확인해주세요."
        case .timeout:
            return "요청 시간이 초과되었습니다.\n다시 시도해주세요."
        case .cancelled:
            return "요청이 취소되었습니다."
        case .unknown:
            return "네트워크 오류가 발생했습니다."
        }
    }
}

// MARK: - Server Errors

struct ServerError: Error {
    let errorClassName: String
    let message: String
    let statusCode: Int

    init(errorClassName: String, message: String, statusCode: Int) {
        self.errorClassName = errorClassName
        self.message = message
        self.statusCode = statusCode
    }
}

// MARK: - Server Error Response

struct ServerErrorResponse: Decodable {
    let status: Int
    let success: Bool
    let data: ServerErrorData

    struct ServerErrorData: Decodable {
        let errorClassName: String
        let message: String
    }

    func toServerError() -> ServerError {
        return ServerError(
            errorClassName: data.errorClassName,
            message: data.message,
            statusCode: status
        )
    }
}
