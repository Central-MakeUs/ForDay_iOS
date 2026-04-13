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
        print("🟡 [ErrorHandling] handleActivityDetailError 호출됨: \(error)")

        // 에러별 ErrorViewController 표시
        if case .server(let serverError) = error {
            print("🟡 [ErrorHandling] ServerError 감지: \(serverError.errorClassName)")

            switch serverError.errorClassName {
            case "ACTIVITY_RECORD_NOT_FOUND", "FRIEND_ONLY_ACCESS", "PRIVATE_RECORD":
                // 404, 403: 조회 불가한 활동 기록
                print("🟢 [ErrorHandling] ErrorViewController로 교체 시작")
                replaceWithErrorViewController(
                    icon: .Icon.error,
                    title: serverError.message,
                    message: "이용에 불편을 드려 죄송합니다."
                )
                return

            default:
                // 그 외 서버 에러는 토스트로 처리
                print("🟡 [ErrorHandling] 기타 서버 에러 - 토스트 표시")
                break
            }
        }

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

    /// 현재 ViewController를 ErrorViewController로 교체
    func replaceWithErrorViewController(
        icon: UIImage,
        title: String,
        message: String
    ) {
        print("🔵 [ErrorHandling] replaceWithErrorViewController 호출됨")
        print("🔵 self: \(type(of: self))")
        print("🔵 navigationController: \(String(describing: navigationController))")

        guard let navigationController = navigationController else {
            print("❌ [ErrorHandling] navigationController가 없음")
            return
        }

        print("🔵 [ErrorHandling] 현재 viewControllers: \(navigationController.viewControllers.map { type(of: $0) })")

        let errorVC = ErrorViewController(icon: icon, title: title, message: message)

        // 현재 navigation stack에서 마지막 VC 제거 후 ErrorVC push
        var viewControllers = navigationController.viewControllers
        if !viewControllers.isEmpty {
            viewControllers.removeLast()
        }
        viewControllers.append(errorVC)

        print("🔵 [ErrorHandling] 새 viewControllers: \(viewControllers.map { type(of: $0) })")

        navigationController.setViewControllers(viewControllers, animated: false)

        // ErrorViewController에서 navigation bar를 숨기므로 여기서 명시적으로 설정
        navigationController.setNavigationBarHidden(true, animated: false)

        print("✅ [ErrorHandling] ErrorViewController로 교체 완료")
    }
}
