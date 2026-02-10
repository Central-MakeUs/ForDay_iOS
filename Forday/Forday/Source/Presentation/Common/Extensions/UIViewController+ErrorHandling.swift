//
//  UIViewController+ErrorHandling.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import UIKit

// MARK: - Error Handling Extension

extension UIViewController {

    /// 공통 에러 처리 메서드 - 서버 메시지를 하단 토스트로 표시
    /// - Parameters:
    ///   - error: AppError 타입의 에러
    ///   - apiErrorMetadata: API별 에러 메타데이터 (optional)
    ///   - customHandler: 커스텀 에러 처리 클로저 (optional)
    func handleAppError(
        _ error: AppError,
        using apiErrorMetadata: ((ServerError) -> APIErrorMetadata?)? = nil,
        customHandler: ((AppError) -> Bool)? = nil
    ) {
        // 커스텀 핸들러가 있고, 처리를 완료했으면 종료
        if let customHandler = customHandler, customHandler(error) {
            return
        }

        // 에러 메시지를 토스트로 표시
        ToastView.showError(message: error.userMessage)
    }
}

// MARK: - Convenience Methods

extension UIViewController {

    /// 활동 기록 API 에러 처리
    func handleActivityRecordError(
        _ error: AppError,
        customHandler: ((AppError) -> Bool)? = nil
    ) {
        handleAppError(error, customHandler: customHandler)
    }

    /// 활동 상세 API 에러 처리
    func handleActivityDetailError(
        _ error: AppError,
        onRetry: (() -> Void)? = nil
    ) {
        handleAppError(error)
    }

    /// 사용자 API 에러 처리
    func handleUserError(
        _ error: AppError,
        customHandler: ((AppError) -> Bool)? = nil
    ) {
        handleAppError(error, customHandler: customHandler)
    }

    /// 취미 API 에러 처리
    func handleHobbyError(
        _ error: AppError,
        customHandler: ((AppError) -> Bool)? = nil
    ) {
        handleAppError(error, customHandler: customHandler)
    }

    /// 반응 API 에러 처리
    func handleReactionError(
        _ error: AppError,
        customHandler: ((AppError) -> Bool)? = nil
    ) {
        handleAppError(error, customHandler: customHandler)
    }
}
