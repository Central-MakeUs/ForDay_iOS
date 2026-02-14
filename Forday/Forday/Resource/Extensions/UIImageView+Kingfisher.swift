//
//  UIImageView+Kingfisher.swift
//  Forday
//
//  Created by Subeen on 2/14/26.
//

import UIKit
import Kingfisher

extension UIImageView {

    /// 기본 placeholder(.bg003) 설정으로 이미지 로드
    /// - Parameters:
    ///   - url: 이미지 URL
    ///   - forceRefresh: 캐시 무시하고 항상 새로 받아올지 여부
    ///   - completion: 완료 콜백
    func setImage(
        with url: URL?,
        forceRefresh: Bool = false,
        completion: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) {
        backgroundColor = .bg003

        guard let url = url else {
            image = nil
            return
        }

        var options: KingfisherOptionsInfo = [
            .transition(.fade(0.2)),
            .cacheOriginalImage
        ]

        if forceRefresh {
            options.append(.forceRefresh)
        }

        kf.setImage(
            with: url,
            options: options
        ) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure:
                self?.image = nil
            }
            completion?(result)
        }
    }

    /// URL 문자열로 이미지 로드
    /// - Parameters:
    ///   - urlString: 이미지 URL 문자열
    ///   - forceRefresh: 캐시 무시하고 항상 새로 받아올지 여부
    ///   - completion: 완료 콜백
    func setImage(
        with urlString: String?,
        forceRefresh: Bool = false,
        completion: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil
    ) {
        guard let urlString = urlString, !urlString.isEmpty else {
            backgroundColor = .bg003
            image = nil
            return
        }

        let url = URL(string: urlString)
        setImage(with: url, forceRefresh: forceRefresh, completion: completion)
    }
}
